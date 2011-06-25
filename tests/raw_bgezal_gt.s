.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test bgezal (branch on greater than or equal to zero and link, signed),
# greater than case.  Confirm that branch decision is correct, control flow
# is as expected, that $ra is properly assigned.
#

start:
		dla	$a4, desired_return_address
		li	$t0, 1
		li	$a0, 1			# Before
		bgezal	$t0, bgezal_target
		li	$a1, 2			# Branch-delay slot
desired_return_address:
		li	$a2, 3			# Shouldn't run
bgezal_target:
		li	$a3, 4			# Should run

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end
