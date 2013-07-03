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
        nop
        nop

        # BEGIN TESTS
        lui $s0, 0x3F80 # 1
        mtc1 $s0, $f0 # move 1 to copro
        dla $t0, positive # load the address
        swc1 $f0, 0($t0) # store 1 in the memory
        lwc1 $f0, 0($t0) # load it back out from the memory 
        mfc1 $s0, $f0 # move it back into s0

        lui $s1, 0xBF80 # -1
        mtc1 $s1, $f1
        dla $t0, negative
        swc1 $f1, 0($t0)
        lwc1 $f1, 0($t0)
        mfc1 $s1, $f1

        lui $s2, 0x4180 # 16
        lui $s3, 0x3D80 # 0.0625 = 1/16
        mtc1 $s2, $f2
        mtc1 $s3, $f3
        dla $t0, loc1
        swc1 $f2, 0($t0)
        swc1 $f3, 4($t0)
        lwc1 $f2, 0($t0)
        lwc1 $f3, 4($t0)
        mfc1 $s2, $f2
        mfc1 $s3, $f3
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
positive:   .word   0xdeadbeef
negative:   .word   0xdeadbeef
loc1:       .word   0xdeadbeef
loc2:       .word   0xdeadbeef
