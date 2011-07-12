.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test bgtz (branch on greater than zero, signed), greater than case and
# backward jump.  Of course, this first requires a forward jump.
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

forward_target:
		li	$a0, 1		# before
		li	$t0, 1
		bgtz	$t0, back_target
		li	$a1, 2		# branch-delay slot
		li	$a2, 3		# shouldn't run
