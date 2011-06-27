.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test that load double words from memory.  Unlike shorter loads, there
# is no distinction between sign-extended and unsigned loads, but we do
# positive and negative variations to check all is well.
#
		.text
start:
		# Load double words
		ld	$a0, dword
		ld	$a1, positive
		ld	$a2, negative

		# Load double words at non-zero offsets
		dla	$t0, val1
		ld	$a3, 8($t0)
		dla	$t1, val2
		ld	$a4, -8($t1)

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
positive:	.dword	0x7fffffffffffffff
negative:	.dword	0xffffffffffffffff
val1:		.dword	0x0000000000000001
val2:		.dword	0x0000000000000002
