#include <mach/mach.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>

struct memory {
    host_t host;
    mach_msg_type_number_t count;
    vm_statistics_data_t vm_info;
    vm_statistics_data_t prev_vm_info;
    bool has_prev_info;

    int used_memory;
    int free_memory;
    int total_memory;
    int memory_load_percentage;
};

static inline void memory_init(struct memory* mem) {
    mem->host = mach_host_self();
    mem->count = HOST_VM_INFO_COUNT;
    mem->has_prev_info = false;
}

static inline void memory_update(struct memory* mem) {
    kern_return_t error = host_statistics(mem->host,
                                          HOST_VM_INFO,
                                          (host_info_t)&mem->vm_info,
                                          &mem->count);

    if (error != KERN_SUCCESS) {
        printf("Error: Could not read memory host statistics.\n");
        return;
    }

    // Total memory is the sum of wired, active, and inactive pages
    int total_pages = mem->vm_info.wire_count +
                      mem->vm_info.active_count +
                      mem->vm_info.inactive_count +
                      mem->vm_info.free_count;

    // Used memory is wired + active + inactive
    int used_pages = mem->vm_info.wire_count +
                     mem->vm_info.active_count +
                     mem->vm_info.inactive_count;

    mem->total_memory = total_pages * vm_page_size / (1024 * 1024);  // in MB
    mem->used_memory = used_pages * vm_page_size / (1024 * 1024);    // in MB
    mem->free_memory = mem->total_memory - mem->used_memory;

    mem->memory_load_percentage = (double)mem->used_memory / (double)mem->total_memory * 100.0;
}
