.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test that stores double words to, and then loads double words from,
# memory.  Unlike shorter loads, there is no distinction between
# sign-extended and unsigned loads, but we do positive and negative
# variations to check all is well.
#
		.text
start:
		dli	$a0, 0xfedcba9876543210
		sd	$a0, dword
		ld	$a0, dword

		# Store and load double with sign extension
		dli	$a1, 1
		sd	$a1, positive
		ld	$a1, positive

		dli	$a2, -1
		sd	$a2, negative
		ld	$a2, negative

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
positive:	.dword	0x0000000000000000
negative:	.dword	0x0000000000000000
