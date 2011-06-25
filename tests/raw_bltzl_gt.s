.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test bltzl (branch on less than zero likely, signed), greater than case.
#

start:
		li	$a0, 1		# before
		li	$t0, 1
		bltzl	$t0, branch_target
		li	$a1, 2		# branch-delay slot; shouldn't run
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
