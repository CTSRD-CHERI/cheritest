.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test that stores words to, and then loads words from, memory using
# store conditional.  Interruption behaviour is deferred to a higher-level
# test.
#

		.text
start:
		#
		# Store conditional only works against addresses in cached
		# memory.  Calculate a cached address for our data segment,
		# and store pointer in $gp.
		#

		dla	$gp, dword
		dli	$t0, 0x9000000000000000		# Uncached
		dsubu	$gp, $gp, $t0
		dli	$t0, 0x9800000000000000		# Cached, non-coherenet
		daddu	$gp, $gp, $t0

		# Store and load a word into double word storage
		dli	$a0, 0xfedcba98
		sc	$a0, 0($gp)			# @dword
		lwu	$a1, 0($gp)

		# Store and load words with sign extension
		daddiu	$gp, $gp, 8			# @positive
		dli	$a2, 1
		sc	$a2, 0($gp)
		lw	$a3, 0($gp)

		daddiu	$gp, $gp, 4			# @negative
		dli	$a4, -1
		sc	$a4, 0($gp)
		lw	$a5, 0($gp)

		# Store and load words at non-zero offsets
		daddiu	$gp, $gp, 4			# @val1
		dli	$a6, 2
		sc	$a6, 4($gp)
		lw	$a7, 4($gp)

		daddiu	$gp, $gp, 4			# @val2
		dli	$s0, 1
		sc	$s0, -4($gp)
		lw	$s1, -4($gp)

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
val1:		.word	0x00000000
val2:		.word	0x00000000
