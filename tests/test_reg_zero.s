.set mips64
.set noreorder
.set nobopt
.set noat

#
# This test checks that register zero behaves the wave it should: each of
# $t0, $t1, and $t2 should be zero as at the end, as well as $zero.
#

		.global	test
test:		.ent	test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		# Pull an initial value out
		move	$t0, $zero

		# Try storing a value into it from an immediate
		li	$zero, 1
		move	$t1, $zero

		# Try storing a value into it from a temporary register
		li	$t3, 1
		move	$zero, $t3
		move	$t2, $zero

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
