.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test sltu (set on less than)
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
		sltu	$a0, $zero, $zero

		# Greater than, non-negative
		sltu	$a1, $t0, $zero

		# Less than, non-negative
		sltu	$a2, $zero, $t0

		# sltiu does an unsigned comparision, so this should be false
		sltu	$a4, $t1, $zero

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
