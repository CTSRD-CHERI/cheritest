.set mips64
.set noreorder
.set nobopt
.set noat

# Test conversion from single to word works in the coprocessor
    
        .text
        .global start
        .ent start

start:
        # Enable CP1
        dli $t1, 1 << 29
        or $at, $at, $t1
        mtc0 $at, $12
        nop
        nop
        nop
        nop

        # START TEST

        # Loading 1
        li $s0, 0x3F800000
        mtc1 $s0, $f0
        # Performing operation
        trunc.w.s $f0, $f0
        mfc1 $s0, $f0

        # Loading -1
        li $s1, 0xBF800000
        mtc1 $s1, $f0
        # Performing operation
        trunc.w.s $f0, $f0
        mfc1 $s1, $f0

        # Loading 1073741824 = 2^30
        li $s2, 0x4E800000
        mtc1 $s2, $f0
        # Performing operation
        trunc.w.s $f0, $f0
        mfc1 $s2, $f0

        # Loading 107.325
        li $s3, 0x42D6A666
        mtc1 $s3, $f0
        # Performing operation
        trunc.w.s $f0, $f0
        mfc1 $s3, $f0

        # Loading 6.66
        li $s4, 0x40D51EB8
        mtc1 $s4, $f0
        # Performing operation
        trunc.w.s $f0, $f0
        mfc1 $s4, $f0

        # END TEST

# Dump registers and terminate
        mtc0 $at, $26
        nop
        nop
        
        mtc0 $at, $23

end:
        b end
        nop
        .end start


