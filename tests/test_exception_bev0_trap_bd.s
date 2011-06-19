.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test that a BEV=0 trap instruction in a branch delay slot returns the right
# EPC.  EPC should point at the branch rather than the trap instruction.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Set BEV=0
		#
		mfc0	$t0, $12
		dli	$t1, 1 << 22
		nor	$t1, $t1
		and	$t0, $t0, $t1
		mtc0	$t0, $12

		#
		# Set up 'handler' as the RAM exception handler.
		#
		dli	$a0, 0xffffffff80000180
		dla	$a1, bev0_handler
		jal	handler_install
		nop

		#
		# Save the desired EPC value for this exception so we can
		# check it later.
		#
		dla	$a0, desired_epc

		#
		# Clear registers we'll use when testing results later.
		#
		dli	$a1, 0
		dli	$a2, 0
		dli	$a3, 0
		dli	$a4, 0
		dli	$a5, 0

		#
		# Set up a taken branh with a trap instruction in the
		# branch-delay slot.  EPC should point at the branch, not the
		# trap instruction.
		#
		li	$t0, 1
desired_epc:
		bnez	$t0, branch_target
		teqi	$zero, 0
branch_target:

		#
		# Exception return.  If EPC is 4 too high, due to not
		# handling the branch-delay slot right, $a6 will be set but
		# not $a1.
		#
		li	$a1, 1
		li	$a6, 1

return:
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

#
# Exception handler.  This code assumes that the trap is in a branch-delay
# slot, so adds 8 to EPC, and saves the cause and status registers for
# checking.  If EPC isn't adjusted properly, this will turn up in the value of
# $a1.
#
		.ent bev0_handler
bev0_handler:
		li	$a2, 1
		mfc0	$a3, $12	# Status register
		mfc0	$a4, $13	# Cause register
		mfc0	$a5, $14	# EPC
		daddiu	$k0, $a5, 8	# EPC += 8 to bump PC forward on ERET
		mtc0	$k0, $14
		nop			# NOPs to avoid hazard with ERET
		nop			# XXXRW: How many are actually
		nop			# required here?
		nop
		eret
		.end bev0_handler
