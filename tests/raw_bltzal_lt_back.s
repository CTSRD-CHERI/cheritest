.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test bltzal (branch on less than zero and link, signed), less than case,
# backward branch.  Confirm that branch decision is correct, control flow is
# as expected, that $ra is properly assigned.
#

start:
		b forward_target
		nop			# branch-delay slot

back_target:
		li	$a3, 4		# should run

		# Dump registers in the simulator
		mtc0	$v0, $26
		nop
		nop

		# Terminate the simulator
end:
		break
		b end
		nop

forward_target:
		dla	$a4, desired_return_address
		li	$a0, 1
		li	$t0, -1
		bltzal	$t0, back_target
		li	$a1, 2		# branch-delay slot

desired_return_address:
		li	$a2, 3		# shouldn't run
