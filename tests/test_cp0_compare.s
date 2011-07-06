.set mips64
.set noreorder
.set nobopt
.set noat

#
# Exercise CP0 count and compare functionality: read the cycle counter, set
# the compare register to count + 1000, then spin in a loop to see if the
# exception fires.  This is run with post-boot vectors (BEV=0), and also
# requires interrupts to be enabled.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Set up 'handler' as the RAM exception handler.
		#
		jal	bev_clear
		nop
		dla	$a0, bev0_handler
		jal	bev0_handler_install
		nop

		#
		# Read CP0 count, add 1000, install in compare.
		#
		mfc0	$a0, $9		# Read from CP0 count register
		daddiu	$a0, $a0, 1000	# += 1000
		mtc0	$a0, $11	# Write to CP0 compare register
		nop
		nop
		mfc0	$a1, $11	# Read back for test

		#
		# Enable interrupts
		#
		mfc0	$t0, $12	# Read from CP0 status register
		ori	$t0, $t0, 0x80 << 8	# Enable timer interrupt
		ori	$t0, 0x1	# Enable interrupts generally
		mtc0	$t0, $12	# Write to CP0 status register

		#
		# Clear registers we'll use when testing results later.  $a0
		# and $a1 intentionally left un-cleared.
		#
		dli	$a2, 0
		dli	$a3, 0
		dli	$a4, 0
		dli	$a5, 0
		dli	$a6, 0
		dli	$a7, 0

		#
		# The wait loop repeatedly loads the CP0 count register so
		# that the test can see what time the interrupt actually
		# fired.
loop:
		mfc0	$a2, $9
		b	loop
		nop			# Branch-delay slot

		#
		# Exception return.
		#
eret_target:
		li	$a3, 1
		mfc0	$a4, $12	# Status register after ERET

return:
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

#
# Exception handler.  Query CP0 count and status registers so we can make sure
# that the counter is (roughly) right, and that interrupts were left disabled
# when we entered the exception handler.  ERET back to an alternative address
# to make sure interrupts are re-enabled.
#

		.ent bev0_handler
bev0_handler:
		li	$a5, 1
		mfc0	$a6, $12	# Status register
		mfc0	$a7, $13	# Cause register
		dla	$k0, eret_target
		mtc0	$k0, $14
		nop			# NOPs to avoid hazard with ERET
		nop			# XXXRW: How many are actually
		nop			# required here?
		nop
		eret
		.end bev0_handler
