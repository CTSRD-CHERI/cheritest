.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test that loads half words from memory.
#
		.text
start:
		# Load a half word from double word storage
		lhu	$a0, dword

		# Load half words with sign extension
		lh	$a1, positive
		lh	$a2, negative

		# Load half words without sign extension
		lh	$a3, positive
		lh	$a4, negative

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
positive:	.hword	0x7fff
negative:	.hword	0xffff
