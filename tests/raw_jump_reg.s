.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test jump register.  Confirm that we end up in the right place, and that
# the branch delay slot is properly executed.
#

start:
		li	$a0, 1
		dla	$a1, jump_target
		jr	$a1
		li	$a2, 2				# Branch-delay slot
		li	$a3, 3				# Shouldn't run
jump_target:
		li	$a4, 4				# Should run

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end
