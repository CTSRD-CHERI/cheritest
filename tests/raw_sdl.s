.set mips64
.set noreorder
.set nobopt
.set noat

start:
		dla	$a0, dword

		dli	$a1, 0xfedcba9876543210
		sdl	$a1, 0($a0)
		ld	$a1, 0($a0)

		dli	$a2, 0xfedcba9876543210
		sdl	$a2, 1($a0)
		ld	$a2, 0($a0)

		dli	$a3, 0xfedcba9876543210
		sdl	$a3, 2($a0)
		ld	$a3, 0($a0)

		dli	$a4, 0xfedcba9876543210
		sdl	$a4, 3($a0)
		ld	$a4, 0($a0)

		dli	$a5, 0xfedcba9876543210
		sdl	$a5, 4($a0)
		ld	$a5, 0($a0)

		dli	$a6, 0xfedcba9876543210
		sdl	$a6, 5($a0)
		ld	$a6, 0($a0)

		dli	$a7, 0xfedcba9876543210
		sdl	$a7, 6($a0)
		ld	$a7, 0($a0)

		dli	$t0, 0xfedcba9876543210
		sdl	$t0, 7($a0)
		ld	$t0, 0($a0)

		dli	$t1, 0xfedcba9876543210
		sdl	$t1, 8($a0)
		ld	$t1, 8($a0)

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end

		.data
dword:		.dword 0x0000000000000000
