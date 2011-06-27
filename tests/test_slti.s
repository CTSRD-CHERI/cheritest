.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test slti (set on less than immediate)
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
		slti	$a0, $zero, 0

		# Greater than, non-negative
		slti	$a1, $t0, 0

		# Less than, non-negative
		slti	$a2, $zero, 1

		# Equal, negative
		slti	$a3, $t1, -1

		# Greater than, negative
		slti	$a4, $t1, -2

		# Less than, negative
		slti	$a5, $t2, -1

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
