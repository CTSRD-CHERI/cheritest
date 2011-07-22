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
		dla	$t3, dword
		sb	$a0, 0($t3)
		lbu	$a0, 0($t3)

		# Store and load bytes with sign extension
		dli	$a1, 1
		dla	$t3, positive
		sb	$a1, 0($t3)
		lb	$a1, 0($t3)

		dli	$a2, -1
		dla	$t3, negative
		sb	$a2, 0($t3)
		lb	$a2, 0($t3)

		# Store and load bytes without sign extension
		dli	$a3, 1
		dla	$t3, positive
		sb	$a3, 0($t3)
		lbu	$a3, 0($t3)

		dli	$a4, -1
		dla	$t3, negative
		sb	$a4, 0($t3)
		lbu	$a4, 0($t3)

		# Store and load bytes at non-zero offsets
		dla	$t0, val1
		dli	$a5, 2
		sb	$a5, 1($t0)
		lb	$a5, 1($t0)

		dla	$t1, val2
		dli	$a6, 1
		sb	$a6, -1($t1)
		lb	$a6, -1($t1)

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
positive:	.byte	0x00
negative:	.byte	0x00
val1:		.byte	0x00
val2:		.byte	0x00
