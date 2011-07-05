.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test for load linked.  ll comes in only a sign-extended flavour, unlike
# lw.
#
		.text
start:
		# Load a word from double word storage
		ll	$a0, dword

		# Load words with sign extension
		ll	$a1, positive
		ll	$a2, negative

		# Load words at non-zero offsets
		dla	$t0, val1
		ll	$a3, 4($t0)
		dla	$t1, val2
		ll	$a4, -4($t1)

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
positive:	.word	0x7fffffff
negative:	.word	0xffffffff
val1:		.word	0x00000001
val2:		.word	0x00000002
