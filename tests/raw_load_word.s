.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test that loads words from memory
#
		.text
start:
		# Load a word from double word storage
		lwu	$a0, dword

		# Load words with sign extension
		lw	$a1, positive
		lw	$a2, negative

		# Load words without sign extension
		lwu	$a3, positive
		lwu	$a4, negative

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end

		.data
dword:		.dword	0xfedcba9876543210
positive:	.word	0x7fffffff
negative:	.word	0xffffffff
