.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test slt (set on less than)
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		dli	$t0, 1
		dli	$t1, -1
		dli	$t2, -2

		# Equal, non-negative
		slt	$a0, $zero, $zero

		# Greater than, non-negative
		slt	$a1, $t0, $zero

		# Less than, non-negative
		slt	$a2, $zero, $t0

		# Equal, negative
		slt	$a3, $t1, $t1

		# Greater than, negative
		slt	$a4, $t1, $t2

		# Less than, negative
		slt	$a5, $t2, $t1

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
