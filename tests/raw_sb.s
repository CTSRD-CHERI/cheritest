.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test that stores bytes to, and then loads bytes from, memory.
#
		.text
start:
		# Store and load a byte into double word storage
		dli	$a0, 0xfe
		sb	$a0, dword
		lbu	$a0, dword

		# Store and load bytes with sign extension
		dli	$a1, 1
		sb	$a1, positive
		lb	$a1, positive

		dli	$a2, -1
		sb	$a2, negative
		lb	$a2, negative

		# Store and load bytes without sign extension
		dli	$a3, 1
		sb	$a3, positive
		lbu	$a3, positive

		dli	$a4, -1
		sb	$a4, negative
		lbu	$a4, negative

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
positive:	.byte	0x00
negative:	.byte	0x00
