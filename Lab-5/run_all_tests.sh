#!/usr/bin/env bash

set -u

ROOT="$(cd "$(dirname "$0")" && pwd)"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-8}"
LOG_DIR="${LOG_DIR:-$ROOT/test-logs}"
BACKUP_DIR="$(mktemp -d)"

mkdir -p "$LOG_DIR"
cd "$ROOT" || exit 1

cp src/user/initcode.c "$BACKUP_DIR/initcode.c"
cp src/kernel/main.c "$BACKUP_DIR/main.c"

restore_sources() {
    cp "$BACKUP_DIR/initcode.c" src/user/initcode.c
    cp "$BACKUP_DIR/main.c" src/kernel/main.c
    rm -rf "$BACKUP_DIR"
}

trap restore_sources EXIT

restore_main() {
    cp "$BACKUP_DIR/main.c" src/kernel/main.c
}

write_test1_initcode() {
    cat > src/user/initcode.c <<'EOF'
#include "sys.h"

int main() {
    int L[5];
    char *s = "hello, world";

    syscall(SYS_copyout, L);
    syscall(SYS_copyin, L, 5);
    syscall(SYS_copyinstr, s);

    while (1)
        ;
    return 0;
}
EOF
}

write_test2_initcode() {
    cat > src/user/initcode.c <<'EOF'
#include "sys.h"

#define PGSIZE 4096

int main() {
    long long heap_top = 0;

    heap_top = syscall(SYS_brk, 0);
    heap_top = syscall(SYS_brk, heap_top + PGSIZE * 9);
    heap_top = syscall(SYS_brk, heap_top);
    heap_top = syscall(SYS_brk, heap_top - PGSIZE * 5);

    while (1)
        ;
    return 0;
}
EOF
}

write_test3_initcode() {
    cat > src/user/initcode.c <<'EOF'
#include "sys.h"

#define PGSIZE 4096

int main() {
    char tmp[PGSIZE * 4];

    tmp[PGSIZE * 3] = 'h';
    tmp[PGSIZE * 3 + 1] = 'e';
    tmp[PGSIZE * 3 + 2] = 'l';
    tmp[PGSIZE * 3 + 3] = 'l';
    tmp[PGSIZE * 3 + 4] = 'o';
    tmp[PGSIZE * 3 + 5] = '\0';

    syscall(SYS_copyinstr, tmp + PGSIZE * 3);

    tmp[0] = 'w';
    tmp[1] = 'o';
    tmp[2] = 'r';
    tmp[3] = 'l';
    tmp[4] = 'd';
    tmp[5] = '\0';

    syscall(SYS_copyinstr, tmp);

    while (1)
        ;
    return 0;
}
EOF
}

write_test4_main() {
    cat > src/kernel/main.c <<'EOF'
#include "arch/mod.h"
#include "lib/mod.h"
#include "mem/mod.h"
#include "trap/mod.h"
#include "proc/mod.h"

volatile static int started = 0;
volatile static bool over_1 = false, over_2 = false;
volatile static bool over_3 = false, over_4 = false;

void *mmap_list[N_MMAP];

int main() {
    int cpuid = r_tp();

    if (cpuid == 0) {
        print_init();
        printf("cpu %d is booting!\n", cpuid);

        pmem_init();
        mmap_init();
        kvm_init();
        kvm_inithart();
        trap_kernel_init();
        trap_kernel_inithart();

        mmap_show_nodelist();
        printf("\n");

        __sync_synchronize();
        started = 1;

        for (int i = 0; i < N_MMAP / 2; i++)
            mmap_list[i] = mmap_region_alloc();
        over_1 = true;

        while (over_1 == false || over_2 == false)
            ;

        for (int i = 0; i < N_MMAP / 2; i++)
            mmap_region_free(mmap_list[i]);
        over_3 = true;

        while (over_3 == false || over_4 == false)
            ;

        mmap_show_nodelist();
    } else {
        while (started == 0)
            ;
        __sync_synchronize();
        printf("cpu %d is booting!\n", cpuid);
        kvm_inithart();
        trap_kernel_inithart();

        for (int i = N_MMAP / 2; i < N_MMAP; i++)
            mmap_list[i] = mmap_region_alloc();
        over_2 = true;

        while (over_1 == false || over_2 == false)
            ;

        for (int i = N_MMAP / 2; i < N_MMAP; i++)
            mmap_region_free(mmap_list[i]);
        over_4 = true;
    }

    while (1)
        ;
}
EOF
}

write_test5_initcode() {
    cat > src/user/initcode.c <<'EOF'
#include "sys.h"

#define VA_MAX       (1ul << 38)
#define PGSIZE       4096
#define MMAP_END     (VA_MAX - (16 * 256 + 2) * PGSIZE)
#define MMAP_BEGIN   (MMAP_END - 64 * 256 * PGSIZE)

int main() {
    syscall(SYS_mmap, MMAP_BEGIN + 4 * PGSIZE, 3 * PGSIZE);
    syscall(SYS_mmap, MMAP_BEGIN + 10 * PGSIZE, 2 * PGSIZE);
    syscall(SYS_mmap, MMAP_BEGIN + 2 * PGSIZE,  2 * PGSIZE);
    syscall(SYS_mmap, MMAP_BEGIN + 12 * PGSIZE, 1 * PGSIZE);
    syscall(SYS_mmap, MMAP_BEGIN + 7 * PGSIZE, 3 * PGSIZE);
    syscall(SYS_mmap, MMAP_BEGIN, 2 * PGSIZE);
    syscall(SYS_mmap, 0, 10 * PGSIZE);

    syscall(SYS_munmap, MMAP_BEGIN + 10 * PGSIZE, 5 * PGSIZE);
    syscall(SYS_munmap, MMAP_BEGIN, 10 * PGSIZE);
    syscall(SYS_munmap, MMAP_BEGIN + 17 * PGSIZE, 2 * PGSIZE);
    syscall(SYS_munmap, MMAP_BEGIN + 15 * PGSIZE, 2 * PGSIZE);
    syscall(SYS_munmap, MMAP_BEGIN + 19 * PGSIZE, 2 * PGSIZE);
    syscall(SYS_munmap, MMAP_BEGIN + 22 * PGSIZE, 1 * PGSIZE);
    syscall(SYS_munmap, MMAP_BEGIN + 21 * PGSIZE, 1 * PGSIZE);

    while (1)
        ;
    return 0;
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
    make clean > "$log" 2>&1
    timeout "${TIMEOUT_SECONDS}s" make run >> "$log" 2>&1
    status=$?

    if [ "$status" -ne 0 ] && [ "$status" -ne 124 ]; then
        echo "FAIL: make run exited with status $status"
        tail -80 "$log"
        return 1
    fi

    for pattern in "$@"; do
        if ! grep -Fq "$pattern" "$log"; then
            echo "FAIL: missing pattern: $pattern"
            failed=1
        fi
    done

    if [ "$failed" -ne 0 ]; then
        tail -120 "$log"
        return 1
    fi

    echo "PASS: $name"
    echo "log: $log"
    return 0
}

failures=0

restore_main
write_test1_initcode
run_case "test-1-copy" \
    "get a number from user: 1" \
    "get a number from user: 5" \
    "get string for user: hello, world" || failures=$((failures + 1))

restore_main
write_test2_initcode
run_case "test-2-heap" \
    "look event: ret_heap_top = 0x0000000000002000" \
    "grow event: ret_heap_top = 0x000000000000b000" \
    "equal event: ret_heap_top = 0x000000000000b000" \
    "ungrow event: ret_heap_top = 0x0000000000006000" || failures=$((failures + 1))

restore_main
write_test3_initcode
run_case "test-3-stack" \
    "page fault occured! trap id = 15" \
    "ustack_npage: 1 -> 2" \
    "ustack_npage: 2 -> 5" \
    "get string for user: hello" \
    "get string for user: world" || failures=$((failures + 1))

write_test1_initcode
write_test4_main
run_case "test-4-mmap-node-store" \
    "cpu 0 is booting!" \
    "cpu 1 is booting!" \
    "node 0 index = 0" \
    "node 255 index = 255" || failures=$((failures + 1))

restore_main
write_test5_initcode
run_case "test-5-mmap-munmap" \
    "alloced mmap_region: 0x0000003ffb002000 ~ 0x0000003ffb005000" \
    "alloced mmap_region: 0x0000003ffaffe000 ~ 0x0000003ffb015000" \
    "alloced mmap_space:" \
    "empty" || failures=$((failures + 1))

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
