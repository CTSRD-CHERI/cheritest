.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test beq (branch on equal, signed), unequal case.
#

start:
		li	$a0, 1		# before
		li	$t0, 1
		beq	$zero, $t0, branch_target
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
