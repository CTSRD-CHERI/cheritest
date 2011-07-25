.set mips64
.set noreorder
.set nobopt
.set noat

start:
		dla	$a0, alternate
		lwl     $a1, 0($a0)
                lwl     $a2, 1($a0)
                lwl     $a3, 2($a0)
		lwl	$a4, 3($a0)
		lwl	$a5, 4($a0)

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
