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
		ld	$a0, dword
		ld	$a1, positive
		ld	$a2, negative

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
