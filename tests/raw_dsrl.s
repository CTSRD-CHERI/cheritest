.set mips64
.set noreorder
.set nobopt
.set noat

start:
		dli	$a0, 0xfedcba9876543210
		dsrl	$a1, $a0, 0
		dsrl	$a2, $a0, 1
		dsrl	$a3, $a0, 16
		dsrl	$a4, $a0, 31

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
