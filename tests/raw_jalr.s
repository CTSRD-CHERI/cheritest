.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test jump and link register.  Confirm that control flow is roughly as
# expected, that the desired register updated, and that $ra is *not* updated.
#

start:
		li	$a0, 1
		dla	$a1, desired_return_address	# To check $a2 against
		li	$ra, 0				# To get 0 after jalr
		dla	$t0, jal_target			# Load jump target
		jalr	$a2, $t0
		li	$a3, 3				# Branch-delay slot
desired_return_address:
		li	$a4, 4				# Shouldn't run
jal_target:
		li	$a5, 5				# Should run

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
