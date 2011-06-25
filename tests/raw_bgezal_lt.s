.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test bgezal (branch on greater than or equal to zero and link, signed),
# less than case.
#

start:
		li	$a0, 1		# before
		li	$t0, -1
		bgezal	$t0, branch_target
		li	$a1, 2		# branch-delay slot
		li	$a2, 3		# should run
branch_target:

		# Dump registers in the simulator
		mtc0	$v0, $26
		nop
		nop

		# Terminate the simulator
		break
end:
		b end
