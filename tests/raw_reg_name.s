.set mips64
.set noreorder
.set nobopt
.set noat

start:
		# Test here
		dli	$zero, 0		# no-op
		dli	$at, 1
		dli	$v0, 2
		dli	$v1, 3
		dli	$a0, 4
		dli	$a1, 5
		dli	$a2, 6
		dli	$a3, 7
		dli	$a4, 8
		dli	$a5, 9
		dli	$a6, 10
		dli	$a7, 11
		dli	$t0, 12
		dli	$t1, 13
		dli	$t2, 14
		dli	$t3, 15
		dli	$s0, 16
		dli	$s1, 17
		dli	$s2, 18
		dli	$s3, 19
		dli	$s4, 20
		dli	$s5, 21
		dli	$s6, 22
		dli	$s7, 23
		dli	$t8, 24
		dli	$t9, 25
		dli	$k0, 26
		dli	$k1, 27
		dli	$gp, 28
		dli	$sp, 29
		dli	$fp, 30
		dli	$ra, 31

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
