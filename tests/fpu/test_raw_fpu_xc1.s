.set mips64
.set noreorder
.set nobopt
.set noat

        .text
        .global start
        .ent start

start:
        # Enable CP1
        dli $t1, 1 << 29
        or $t0, $t1, $t1
        mtc0 $t0, $12
        nop
        nop
        nop


        # BEGIN TESTS
        dla $t0, word1
        dla $t1, double1
        li $t2, 4 # word single offset
        li $t3, 8 # double single offset

        lui $a0, 0xABCD
        lui $a1, 0x4321
        mtc1 $a0, $f0
        mtc1 $a1, $f1
        swxc1 $f0, $0($t0)
        swxc1 $f1, $t2($t0)
        lwxc1 $f2, $0($t0)
        lwxc1 $f3, $t2($t0)
        mfc1 $s0, $f2
        mfc1 $s1, $f3

        lui $a0, 0xFEED
        dsll $a0, $a0, 32
        lui $a1, 0xFACE
        dsll $a1, $a1, 16 
        dmtc1 $a0, $f0
        dmtc1 $a1, $f1
        sdxc1 $f0, $0($t1)
        sdxc1 $f1, $t3($t1)
        ldxc1 $f2, $0($t1)
        ldxc1 $f3, $t3($t1)
        dmfc1 $s2, $f2
        dmfc1 $s3, $f3
        # END TESTS

		# Dump registers on the simulator (gxemul dumps regs on exit)
		mtc0 $at, $26
		nop
		nop

		# Terminate the simulator
		mtc0 $at, $23
end:
		b end
		nop
		.end start
 
        .data
word1:      .word   0x00000000
word2:      .word   0x00000000
double1:    .dword  0x0000000000000000
double2:    .dword  0x0000000000000000
