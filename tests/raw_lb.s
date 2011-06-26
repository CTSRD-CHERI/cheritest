.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test that loads bytes from memory.
#
		.text
start:
		# Load a byte from double word storage
		lbu	$a0, dword

		# Load bytes with sign extension
		lb	$a1, positive
		lb	$a2, negative

		# Load bytes without sign extension
		lbu	$a3, positive
		lbu	$a4, negative

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
positive:	.byte	0x7f
negative:	.byte	0xff
