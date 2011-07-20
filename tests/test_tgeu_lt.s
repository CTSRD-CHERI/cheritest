.set mips64
.set noreorder
.set nobopt
.set noat

#
# Exercise trap instruction 'tgeu' (trap if greater than of equal unsigned), "less than" case.
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
		dli	$a2, 0

		#
		# Don't trigger it.
		#
		dli	$t1, 1
		tgeu	$zero, $t1

return:
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

#
# Simple exception handler that shouldn't run; assumes that the trap is not
# from a branch-delay slot or may become confused.
#
		.ent bev0_handler
bev0_handler:
		li	$a2, 1
		dmfc0	$a5, $14	# EPC
		daddiu	$k0, $a5, 4	# EPC += 4 to bump PC forward on ERET
		dmtc0	$k0, $14
		nop			# NOPs to avoid hazard with ERET
		nop			# XXXRW: How many are actually
		nop			# required here?
		nop
		eret
		.end bev0_handler
