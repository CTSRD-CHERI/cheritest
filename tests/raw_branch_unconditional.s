.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test a simple forward branch.  $t0 is assigned before the branch, $t1 in
# the branch-delay slot, $t2 should be skipped, and $t3 at the branch target.
#

start:
		li	$t0, 1
		b	branch_target
		li	$t1, 1		# branch-delay slot
		li	$t2, 1
branch_target:
		li	$t3, 1

		# Dump registers in the simulator
		mtc0	$v0, $26
		nop
		nop

		# Terminate the simulator
		break
end:
		b end
