.set mips64
.set noreorder
.set nobopt

#
# Test which tries the 32-bit division operator with each combination
# of positive and negative arguments.
# Results are 32-bit numbers (sign-extended to 64-bits) which are stored
# in hi (remainder) and lo (quotient)
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		# Test itself goes here
		li	$t0, 123
		li	$t1, 24

		#$zero prevents assembler adding checking instructions
		divu	$zero, $t0, $t1
		mfhi	$a0
		mflo	$a1

		li	$t0, -123
		li	$t1, -24
		divu	$zero, $t0, $t1
		mfhi	$a2
		mflo	$a3

		li	$t0, -123
		li	$t1, 24
		divu	$zero, $t0, $t1
		mfhi	$a4
		mflo	$a5

		li	$t0, 123
		li	$t1, -24
		divu	$zero, $t0, $t1
		mfhi	$a6
		mflo	$a7

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
