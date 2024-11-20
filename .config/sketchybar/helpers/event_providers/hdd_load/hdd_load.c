#include "hdd.h"
#include "../sketchybar.h"
#include <sys/statvfs.h>

int main (int argc, char** argv) {
    float update_freq;
    if (argc < 3 || (sscanf(argv[2], "%f", &update_freq) != 1)) {
        printf("Usage: %s \"<event-name>\" \"<event_freq>\"\n", argv[0]);
        exit(1);
    }

    alarm(0);
    struct disk_info disk;
    disk_init(&disk);

    // Setup the event in sketchybar
    char event_message[512];
    snprintf(event_message, 512, "--add event '%s'", argv[1]);
    sketchybar(event_message);

    char trigger_message[512];
    for (;;) {
        // Acquire new disk info
        disk_update(&disk);

        // Prepare the event message
        snprintf(trigger_message,
                 512,
                 "--trigger '%s' total_space='%dGB' free_space='%dGB' used_space='%dGB' percent_used='%02d%%' percent_remaining='%02d%%'",
                 argv[1],
                 disk.total_space,
                 disk.free_space,
                 disk.used_space,
                 disk.percent_used,
                 disk.percent_remaining);

        // Trigger the event
        sketchybar(trigger_message);

        // Debugging output
        printf("Trigger message: %s\n", trigger_message); // Debugging

        // Wait
        usleep(update_freq * 1000000);
    }
    return 0;
}
