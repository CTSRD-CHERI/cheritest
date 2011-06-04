.set mips64
.set noreorder
.set nobopt
.set noat

#
# This test checks the initialisation-time defaults for selected CP0
# registers by copying them into general-purpose registers that predicates can
# check directly.
#

		.global test
test:		.ent test
		addu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		addu	$fp, $sp, 32

		# Context Register
		mfc0	$a0, $4

		# Wired Register
		mfc0	$a1, $6

		# Count Register
		mfc0	$a2, $9

		# Status Register
		mfc0	$a3, $12

		# Processor Revision Identifier (PRId)
		mfc0	$a4, $15

		# Config Register
		mfc0	$a5, $16

		# XContext Register
		mfc0	$a6, $20

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		addu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
