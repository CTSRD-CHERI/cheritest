.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test that stores words to, and then loads words from, memory.
#
		.text
start:
		# Store and load a word into double word storage
		dli	$a0, 0xfedcba98
		sw	$a0, dword
		lwu	$a0, dword

		# Store and load words with sign extension
		dli	$a1, 1
		sw	$a1, positive
		lw	$a1, positive

		dli	$a2, -1
		sw	$a2, negative
		lw	$a2, negative

		# Store and load words without sign extension
		dli	$a3, 1
		sw	$a3, positive
		lwu	$a3, positive

		dli	$a4, -1
		sw	$a4, negative
		lwu	$a4, negative

		# Store and load words at non-zero offsets
		dla	$t0, val1
		dli	$a5, 2
		sw	$a5, 4($t0)
		lw	$a5, 4($t0)

		dla	$t1, val2
		dli	$a6, 1
		sw	$a6, -4($t1)
		lw	$a6, -4($t1)

		# Dump registers in the simulator
		mtc0	$v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end

		.data
dword:		.dword	0x0000000000000000
positive:	.word	0x00000000
negative:	.word	0x00000000
val1:		.word	0x00000000
val2:		.word	0x00000000
