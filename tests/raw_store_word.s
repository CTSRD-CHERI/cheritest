.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test that stores words to, and then loads bytes from, memory.
#
		.text
start:
		# Store and load a byte into double word storage
		dli	$a0, 0xfedcba98
		sw	$a0, dword
		lwu	$a0, dword

		# Store and load bytes with sign extension
		dli	$a1, 1
		sw	$a1, positive
		lw	$a1, positive

		dli	$a2, -1
		sw	$a2, negative
		lw	$a2, negative

		# Store and load bytes without sign extension
		dli	$a3, 1
		sw	$a3, positive
		lwu	$a3, positive

		dli	$a4, -1
		sw	$a4, negative
		lwu	$a4, negative

		# Dump registers in the simulator
		mtc0	$v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end

		.data
dword:		.dword	0x0000000000000000
positive:	.word	0x00000000
negative:	.word	0x00000000
