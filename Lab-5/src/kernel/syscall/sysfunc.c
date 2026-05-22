#include "mod.h"

/*
    测试: 从用户空间传入一个int类型的数组
    uint64 addr 数组起始地址
    uint32 len  元素数量
    成功返回0
*/
uint64 sys_copyin() {
    proc_t *p = myproc();
    uint64 addr;
    uint32 len;
    int32 nums[16];

    arg_uint64(0, &addr);
    arg_uint32(1, &len);
    if (len == 0 || len > 16)
        return -1;

    uvm_copyin(p->pgtbl, (uint64)nums, addr, len * sizeof(int32));
    for (uint32 i = 0; i < len; i++)
        printf("get a number from user: %d\n", nums[i]);

    return 0;
}

/*
    测试: 向用户空间传出一个int类型的数组
    uint64 addr 数组起始地址
    成功返回拷贝的元素数量
*/
uint64 sys_copyout() {
    proc_t *p = myproc();
    uint64 addr;
    int32 nums[5] = {1, 2, 3, 4, 5};

    arg_uint64(0, &addr);
    uvm_copyout(p->pgtbl, addr, (uint64)nums, sizeof(nums));

    return 5;
}

/*
    测试: 从用户空间传入一个字符串
    uint64 addr 字符串起始地址
    成功返回0
*/
uint64 sys_copyinstr() {
    char buf[STR_MAXLEN + 1];

    arg_str(0, buf, STR_MAXLEN);
    printf("get string for user: %s\n", buf);
    return 0;
}

/*
    用户堆空间伸缩
    uint64 new_heap_top (如果是0, 代表查询当前堆顶位置)
    成功返回new_heap_top, 失败返回-1
*/
uint64 sys_brk() {
    proc_t *p = myproc();
    uint64 new_heap_top;
    uint64 old_heap_top;
    uint64 ret_heap_top;

    arg_uint64(0, &new_heap_top);
    if (new_heap_top == 0) {
        printf("look event: ret_heap_top = %p\n", p->heap_top);
        vm_print(p->pgtbl);
        printf("\n");
        return p->heap_top;
    }

    if (new_heap_top < USER_BASE + PGSIZE || new_heap_top > MMAP_BEGIN)
        return -1;

    old_heap_top = p->heap_top;
    if (new_heap_top > old_heap_top) {
        ret_heap_top = uvm_heap_grow(p->pgtbl, old_heap_top, new_heap_top - old_heap_top);
        printf("grow event: ret_heap_top = %p\n", ret_heap_top);
    } else if (new_heap_top < old_heap_top) {
        ret_heap_top = uvm_heap_ungrow(p->pgtbl, old_heap_top, old_heap_top - new_heap_top);
        printf("ungrow event: ret_heap_top = %p\n", ret_heap_top);
    } else {
        ret_heap_top = p->heap_top;
        printf("equal event: ret_heap_top = %p\n", ret_heap_top);
    }

    p->heap_top = ret_heap_top;
    vm_print(p->pgtbl);
    printf("\n");
    return p->heap_top;
}

/*
    增加一段内存映射
    uint64 start 起始地址
    uint32 len   范围 (字节,需检查是否是page-aligned)
    成功返回映射空间的起始地址, 失败返回-1
*/
uint64 sys_mmap() {
    uint64 start;
    uint32 len;
    uint64 mapped;

    arg_uint64(0, &start);
    arg_uint32(1, &len);
    if (len == 0 || len % PGSIZE != 0)
        return -1;
    if (start != 0 && (start % PGSIZE != 0 || start < MMAP_BEGIN || start + len > MMAP_END))
        return -1;

    mapped = uvm_mmap(start, len / PGSIZE, PTE_R | PTE_W | PTE_U);
    uvm_show_mmaplist(myproc()->mmap);
    vm_print(myproc()->pgtbl);
    printf("\n");
    return mapped;
}

/*
    解除一段内存映射
    uint64 start 起始地址
    uint32 len   范围 (字节, 需检查是否是page-aligned)
    成功返回0 失败返回-1
*/
uint64 sys_munmap() {
    uint64 start;
    uint32 len;

    arg_uint64(0, &start);
    arg_uint32(1, &len);
    if (len == 0 || len % PGSIZE != 0)
        return -1;
    if (start % PGSIZE != 0 || start < MMAP_BEGIN || start + len > MMAP_END)
        return -1;

    uvm_munmap(start, len / PGSIZE);
    uvm_show_mmaplist(myproc()->mmap);
    vm_print(myproc()->pgtbl);
    printf("\n");
    return 0;
}
