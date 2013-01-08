# Number of threads per core for multi-threaded tests.
# Hard coded to 2 at the moment. Single-threaded tests should
# run fine even if there is only one hw thread.
thread_count = 2

# Create the data structure used for thread barriers.
# Should be placed in .data section.
# No particular alignment is required.
.macro mkBarrier
        .rept thread_count
        .byte 0
        .endr
.endm
