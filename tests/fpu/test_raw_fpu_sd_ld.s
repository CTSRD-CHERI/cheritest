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

        dla $t0, preload
        ldc1 $f0, 0($t0)
        dmfc1 $s0, $f0

        dla $t0, loc1
        lui $t1, 0xBED0
        dsll $t1, 32
        dmtc1 $t1, $f0
        sdc1 $f0, 0($t0)
        ldc1 $f1, 0($t0)
        dmfc1 $s1, $f1
        lui $t1, 0x1212
        dsll $t1, 32
        dmtc1 $t1, $f0
        sdc1 $f0, 8($t0)
        ldc1 $f2, 8($t0)
        dmfc1 $s2, $f2

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
preload:    .dword   0x0123456789abcdef
loc1:       .dword   0x0000000000000000
loc2:       .dword   0x0000000000000000
