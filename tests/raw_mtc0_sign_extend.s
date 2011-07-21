.set mips64
.set noreorder
.set nobopt
.set noat

start:
		li	$a0, 0xffff
		dsll	$a0, $a0, 16
		mtc0	$a0, $14

		nop
		nop
		nop
		nop

		mfc0	$a1, $14
		dmfc0	$a2, $14

		dmtc0	$a0, $14

		nop
		nop
		nop
		nop

		mfc0	$a3, $14
		dmfc0	$a4, $14

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
