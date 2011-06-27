.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unaligned lw, firing an address exception.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Set up exception handler.
		#
		jal	bev_clear
		nop
		dla	$a0, bev0_handler
		jal	bev0_handler_install
		nop

		#
		# Clear registers we'll use when testing results later.
		#
		dli	$a0, 0
		dli	$a1, 0
		dli	$a2, 0
		dli	$a3, 0
		dli	$a4, 0
		dli	$a5, 0
		dli	$a6, 0
		dli	$a7, 0

		#
		# Save the desired EPC value for this exception so we can
		# check it later.
		#
		dla	$a0, desired_epc

		#
		# Trigger exception.
		#
		dla	$t0, bytes
desired_epc:
		lw	$a7, 1($t0)

		#
		# Exception return.
		#
		li	$a1, 1
		mfc0	$a6, $12	# Status register after ERET

return:
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

#
# Our actual exception handler, which tests various properties.  This code
# assumes that the overflow wasn't in a branch-delay slot (and the test code
# checks BD as well), so EPC += 4 should return control after the overflow
# instruction.
#
		.ent bev0_handler
bev0_handler:
		li	$a2, 1
		mfc0	$a3, $12	# Status register
		mfc0	$a4, $13	# Cause register
		mfc0	$a5, $14	# EPC
		daddiu	$k0, $a5, 4	# EPC += 4 to bump PC forward on ERET
		mtc0	$k0, $14
		nop			# NOPs to avoid hazard with ERET
		nop			# XXXRW: How many are actually
		nop			# required here?
		nop
		eret
		.end bev0_handler

		.data
		.align	5
bytes:		.dword	0x5656565656565656
		.dword	0x7878787878787878
