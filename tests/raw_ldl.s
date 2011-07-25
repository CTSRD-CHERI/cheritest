.set mips64
.set noreorder
.set nobopt
.set noat

start:
		dla	$a0, testword
		ldl	$a1, 0($a0)
		ldl	$a2, 4($a0)
		ldl	$a3, 8($a0)

		dla	$a0, alternate
		ldl     $a4, 0($a0)
                ldl     $a5, 4($a0)
                ldl     $a6, 8($a0)

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end

		.data
testword:	.dword 0xffffffffffffffff
alternate:	.dword 0xfedcba9876543210
