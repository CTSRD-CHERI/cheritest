.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test for load linked.
#
		.text
start:
		# Load double words
		lld	$a0, dword
		lld	$a1, positive
		lld	$a2, negative

		# Load double words at non-zero offsets
		dla	$t0, val1
		lld	$a3, 8($t0)
		dla	$t1, val2
		lld	$a4, -8($t1)

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end

		.data
dword:		.dword	0xfedcba9876543210
positive:	.dword	0x7fffffffffffffff
negative:	.dword	0xffffffffffffffff
val1:		.dword	0x0000000000000001
val2:		.dword	0x0000000000000002
