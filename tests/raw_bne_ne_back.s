.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test bne (branch on not equal), not equal case and backward jump.  Of
# course, this first requires a forward jump.
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
		break
end:
		b end

forward_target:
		li	$a0, 1		# before
		li	$t0, 1
		bne	$t0, $zero, back_target
		li	$a1, 2		# branch-delay slot
		li	$a2, 3		# shouldn't run
