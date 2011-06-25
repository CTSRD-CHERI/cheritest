.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test bgezall (branch on greater than or equal to zero and link likely,
# signed), equal case.  Confirm that branch decision is correct, control flow
# is as expected, that $ra is properly assigned.
#

start:
		dla	$a4, desired_return_address
		li	$a0, 1			# Before
		bgezall	$zero, bgezall_target
		li	$a1, 2			# Branch-delay slot
desired_return_address:
		li	$a2, 3			# Shouldn't run
bgezall_target:
		li	$a3, 4			# Should run

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end
