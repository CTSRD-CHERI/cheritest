.set mips64
.set noreorder
.set nobopt
.set noat

#
# Load an immediate into $t1, then move to $t2.
#

		.global	test
test:		.ent	test
		daddu 	$sp, $sp, -32

		dli	$t1, 0xfedcba9876543210
		move	$t2, $t1

		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
