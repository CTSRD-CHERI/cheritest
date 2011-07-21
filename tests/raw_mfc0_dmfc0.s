.set mips64
.set noreorder
.set nobopt
.set noat

start:
		# Test here
		
		dla	$a0, epc_target
		dmtc0	$a0, $14

		nop
		nop
		nop
		nop

		mfc0	$a1, $14
		dmfc0	$a2, $14
		eret
		nop
		nop
		nop

		li	$a3, 1
epc_target:		
		li	$a4, 2

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
