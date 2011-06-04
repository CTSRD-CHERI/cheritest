.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test jump and link.  There are two testing goals:
#
# (1) Confirm that control flow is roughly as expected.
# (2) Confirm that $ra is properly assigned.
#

start:

		li	$t0, 1
		dla	$t8, desired_return_address	# To check $ra against
		jal	jal_target
		li	$t1, 2				# Branch-delay slot
desired_return_address:
		li	$t2, 3				# Shouldn't run
jal_target:
		li	$t3, 4				# Should run

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end
