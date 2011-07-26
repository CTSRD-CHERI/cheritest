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
		swr	$a0, 0($t0)
		ld	$a0, 0($t0)

		dli	$a1, 0xfedcba98
		swr	$a1, 4($t0)
		ld	$a1, 0($t0)

		dli	$a2, 0xfedcba98
		swr	$a2, 2($t0)
		ld	$a2, 0($t0)

		dli	$a3, 0xfedcba98
		swr	$a3, 7($t0)
		ld	$a3, 0($t0)

		dli	$a4, 0xfedcba98
		swr	$a4, 5($t0)
		ld	$a4, 0($t0)


		#Terminate the simulator
		mtc0	$v0, $26
end:
		b	end


		.data
dword:		.dword 0x0000000000000000
