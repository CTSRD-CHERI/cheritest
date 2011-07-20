.set mips64
.set noreorder
.set nobopt
.set noat

#
# This test checks two properties of eret:
#
# (1) It must clear the EXL flag in the status register
# (2) It must jump to EPC without a branch delay slot
#
# In the future, it might be useful to also have an error trap test that works
# with ERL rather than EXL.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		# Set EXL manually
		mfc0	$a0, $12
		ori	$a0, 1 << 1
		mtc0	$a0, $12
		nop
		nop
		mfc0	$a0, $12	# Saved to let us check EXL stuck

		# Configure a target EPC
		dla	$t0, epc_target
		dmtc0	$t0, $14

		nop			# NOPs to avoid hazard with ERET
		nop			# XXXRW: How many are actually
		nop			# required here?
		nop

		li	$a1, 1		# Should run
		eret
		li	$a2, 2		# Shouldn't run (not a branch delay!)
		li	$a3, 3		# Shouldn't run (eret jumps to new EPC)
epc_target:
		li	$a4, 4		# Should run
		mfc0	$a5, $12	# Status register to check EXL again

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
