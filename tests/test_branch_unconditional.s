.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test a simple forward branch.  $t0 is assigned before the branch, $t1 in
# the branch-delay slot, $t2 should be skipped, and $t3 at the branch target.
#

		.global	test
test:		.ent	test
		addu 	$sp, $sp, -32

		li	$t0, 1
		b	branch_target
		li	$t1, 1		# branch-delay slot
		li	$t2, 1
branch_target:
		li	$t3, 1

		addu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
