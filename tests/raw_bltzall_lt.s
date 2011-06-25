.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test bltzall (branch on less than zero and link likely, signed), less than
# case.  Confirm that branch decision is correct, control flow is as
# expected, that $ra is properly assigned.
#

start:
		dla	$a4, desired_return_address
		li	$a0, 1			# Before
		li	$t0, -1
		bltzall	$t0, bltzall_target
		li	$a1, 2			# Branch-delay slot
desired_return_address:
		li	$a2, 3			# Shouldn't run
bltzall_target:
		li	$a3, 4			# Should run

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end
