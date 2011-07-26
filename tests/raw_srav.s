.set mips64
.set noreorder
.set nobopt
.set noat

start:
		dli	$a0, 0xfedcba9876543210

		li	$a1, 0
		srav	$a1, $a0, $a1

		li	$a2, 1
		srav	$a2, $a0, $a2

		li	$a3, 16
		srav	$a3, $a0, $a3

		li	$a4, 31
		srav	$a4, $a0, $a4

		dli	$a5, 0x00000000ffffffff
		li	$a6, 0 
		srav	$a6, $a5, $a6

		li	$a7, 1
		srav	$a7, $a5, $a7

		li	$t0, 16
		srav	$t0, $a5, $t0

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
