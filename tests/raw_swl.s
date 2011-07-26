.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test that stores partial words to, and the loads full words from, memory.
#
		.text
start:
		dli	$a0, 0xfedcba98
		dla	$t0, dword
		swl	$a0, 0($t0)
		lw	$a0, 0($t0)

		dli	$a1, 0xfedcba98
		swl	$a1, 4($t0)
		lw	$a1, 4($t0)

		dli	$a2, 0x00000000
		swl	$a2, 2($t0)
		lw	$a2, 0($t0)

		dli	$a3, 0x00000000
		swl	$a3, 5($t0)
		lw	$a3, 4($t0)

		dli	$a4, 0xfedcba98
		swl	$a4, 7($t0)
		lw	$a4, 4($t0)


		#Terminate the simulator
		mtc0	$v0, $26
end:
		b	end


		.data
dword:		.dword 0x0000000000000000
