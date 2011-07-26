.set mips64
.set noreorder
.set nobopt
.set noat

start:
		dli	$a0, 0xfedcba9876543210
		srl	$a1, $a0, 0
		srl	$a2, $a0, 1
		srl	$a3, $a0, 16
		srl	$a4, $a0, 31

		dli	$a5, 0x00000000ffffffff
		srl	$a6, $a5, 0

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
