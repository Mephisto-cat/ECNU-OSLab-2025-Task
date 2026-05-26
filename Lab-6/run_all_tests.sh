#!/usr/bin/env bash

set -u

ROOT="$(cd "$(dirname "$0")" && pwd)"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-8}"
LOG_DIR="${LOG_DIR:-$ROOT/test-logs}"
BACKUP_DIR="$(mktemp -d)"

mkdir -p "$LOG_DIR"
cd "$ROOT" || exit 1
rm -f "$LOG_DIR"/test-*.log "$LOG_DIR"/test-*.run.log "$LOG_DIR"/test-*.raw.log

cp src/user/initcode.c "$BACKUP_DIR/initcode.c"

restore_sources() {
    cp "$BACKUP_DIR/initcode.c" src/user/initcode.c
    rm -rf "$BACKUP_DIR"
}

trap restore_sources EXIT

write_test1_initcode() {
    cat > src/user/initcode.c <<'EOF'
#include "sys.h"

int main() {
    int pid = syscall(SYS_getpid);

    if (pid == 1) {
        syscall(SYS_print_str, "\nproczero: hello ");
        syscall(SYS_print_str, "world!\n");
    }

    while (1) {
        ;
    }
}
EOF
}

write_test2_initcode() {
    cat > src/user/initcode.c <<'EOF'
#include "sys.h"

int main() {
    syscall(SYS_sched_trace, 1);
    syscall(SYS_print_str, "proc 1 is running...\n");
    syscall(SYS_print_str, "level-1!\n");
    syscall(SYS_fork);
    syscall(SYS_print_str, "level-2!\n");
    syscall(SYS_fork);
    syscall(SYS_print_str, "level-3!\n");

    while (1) {
        ;
    }
}
EOF
}

write_test3_initcode() {
    cat > src/user/initcode.c <<'EOF'
#include "sys.h"

#define PGSIZE 4096
#define VA_MAX (1ul << 38)
#define MMAP_END (VA_MAX - (2 + 16 * 256) * PGSIZE)
#define MMAP_BEGIN (MMAP_END - 64 * 256 * PGSIZE)

int main() {
    int pid, i;
    char *str1, *str2, *str3 = "STACK_REGION\n\n";
    char *tmp1 = "MMAP_REGION\n", *tmp2 = "HEAP_REGION\n";

    str1 = (char *)syscall(SYS_mmap, MMAP_BEGIN, PGSIZE);
    for (i = 0; tmp1[i] != '\0'; i++) {
        str1[i] = tmp1[i];
    }
    str1[i] = '\0';

    str2 = (char *)syscall(SYS_brk, 0);
    syscall(SYS_brk, (long long int)str2 + PGSIZE);
    for (i = 0; tmp2[i] != '\0'; i++) {
        str2[i] = tmp2[i];
    }
    str2[i] = '\0';

    syscall(SYS_print_str, "\n--------test begin--------\n");
    pid = syscall(SYS_fork);

    if (pid == 0) {
        syscall(SYS_print_str, "child proc: hello!\n");
        syscall(SYS_print_str, str1);
        syscall(SYS_print_str, str2);
        syscall(SYS_print_str, str3);
        syscall(SYS_exit, 1234);
    } else {
        int exit_state = 0;
        syscall(SYS_wait, &exit_state);
        syscall(SYS_print_str, "parent proc: hello!\n");
        syscall(SYS_print_int, pid);
        if (exit_state == 1234) {
            syscall(SYS_print_str, "good boy!\n");
        } else {
            syscall(SYS_print_str, "bad boy!\n");
        }
    }

    syscall(SYS_print_str, "--------test end----------\n");

    while (1) {
        ;
    }
}
EOF
}

write_test4_initcode() {
    cat > src/user/initcode.c <<'EOF'
#include "sys.h"

int main() {
    int pid = syscall(SYS_fork);

    if (pid == 0) {
        syscall(SYS_print_str, "Ready to sleep!\n");
        syscall(SYS_sleep, 30);
        syscall(SYS_print_str, "Ready to exit!\n");
        syscall(SYS_exit, 0);
    } else {
        syscall(SYS_wait, 0);
        syscall(SYS_print_str, "Child exit!\n");
    }

    while (1) {
        ;
    }
}
EOF
}

run_case() {
    local name="$1"
    shift
    local log="$LOG_DIR/$name.log"
    local status=0
    local failed=0

    printf "\n===== %s =====\n" "$name"
    make clean > /dev/null 2>&1
    if ! make build > /dev/null 2>&1; then
        echo "FAIL: make build failed"
        return 1
    fi

    script -q -e -c \
        "timeout ${TIMEOUT_SECONDS}s qemu-system-riscv64 -machine virt -bios none -kernel build/kernel-qemu.elf -m 128M -smp 2 -nographic" \
        "$log" > /dev/null 2>&1
    status=$?
    sed -i '/^Script started on /d;/^Script done on /d' "$log"
    perl -pi -e 's/\r//g' "$log"

    echo "raw output: $log"
    cat "$log"

    if [ "$status" -ne 0 ] && [ "$status" -ne 124 ]; then
        echo "FAIL: qemu exited with status $status"
        return 1
    fi

    for pattern in "$@"; do
        if ! grep -Fq -- "$pattern" "$log"; then
            echo "FAIL: missing pattern: $pattern"
            failed=1
        fi
    done

    if [ "$failed" -ne 0 ]; then
        return 1
    fi

    echo "PASS: $name"
    return 0
}

require_count() {
    local name="$1"
    local pattern="$2"
    local expected="$3"
    local log="$LOG_DIR/$name.log"
    local actual

    actual="$(grep -F -- "$pattern" "$log" | wc -l)"
    if [ "$actual" -ne "$expected" ]; then
        echo "FAIL: $name expected $expected lines containing '$pattern', got $actual"
        echo "raw output: $log"
        return 1
    fi

    return 0
}

failures=0

write_test1_initcode
run_case "test-1" \
    "cpu 0 is booting!" \
    "cpu 1 is booting!" \
    "proczero: hello world!" || failures=$((failures + 1))

write_test2_initcode
run_case "test-2" \
    "proc 1 is running..." \
    "proc 2 is running..." \
    "proc 3 is running..." \
    "proc 4 is running..." \
    "level-1!" \
    "level-2!" \
    "level-3!" || failures=$((failures + 1))
require_count "test-2" "level-1!" 1 || failures=$((failures + 1))
require_count "test-2" "level-2!" 2 || failures=$((failures + 1))
require_count "test-2" "level-3!" 4 || failures=$((failures + 1))

write_test3_initcode
run_case "test-3" \
    "--------test begin--------" \
    "child proc: hello!" \
    "MMAP_REGION" \
    "HEAP_REGION" \
    "STACK_REGION" \
    "parent proc: hello!" \
    "num = 2" \
    "good boy!" \
    "--------test end----------" || failures=$((failures + 1))

write_test4_initcode
run_case "test-4" \
    "Ready to sleep!" \
    "proc 2 is sleeping!" \
    "proc 2 is wakeup!" \
    "Ready to exit!" \
    "proc 1 is wakeup!" \
    "Child exit!" || failures=$((failures + 1))

restore_sources
trap - EXIT
make clean > /dev/null 2>&1

if [ "$failures" -ne 0 ]; then
    echo
    echo "$failures test(s) failed. See logs in $LOG_DIR"
    exit 1
fi

echo
echo "All tests passed. Logs are in $LOG_DIR"
