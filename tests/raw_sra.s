.set mips64
.set noreorder
.set nobopt
.set noat

start:
		dli	$a0, 0xfedcba9876543210
		sra	$a1, $a0, 0
		sra	$a2, $a0, 1
		sra	$a3, $a0, 16
		sra	$a4, $a0, 31

		dli	$a5, 0x00000000ffffffff
		sra	$a6, $a5, 0
		sra	$a7, $a5, 1
		sra	$t0, $a5, 16

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
