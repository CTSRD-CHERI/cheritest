.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test that stores half words to, and then loads half words from, memory.
#
		.text
start:
		# Store and load a half word into double word storage
		dli	$a0, 0xfedc
		sh	$a0, dword
		lhu	$a0, dword

		# Store and load half words with sign extension
		dli	$a1, 1
		sh	$a1, positive
		lh	$a1, positive

		dli	$a2, -1
		sh	$a2, negative
		lh	$a2, negative

		# Store and load half words without sign extension
		dli	$a3, 1
		sh	$a3, positive
		lhu	$a3, positive

		dli	$a4, -1
		sh	$a4, negative
		lhu	$a4, negative

		# Store and load bytes at non-zero offsets
		dla	$t0, val1
		dli	$a5, 2
		sh	$a5, 2($t0)
		lh	$a5, 2($t0)

		dla	$t1, val2
		dli	$a6, 1
		sh	$a6, -2($t1)
		lh	$a6, -2($t1)

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
positive:	.hword	0x0000
negative:	.hword	0x0000
val1:		.hword	0x0000
val2:		.hword	0x0000
