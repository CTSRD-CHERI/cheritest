.set mips64
.set noreorder
.set nobopt
.set noat

#
# Check that various operations interrupt load linked + store conditional.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Set up nop exception handler.
		#
		jal	bev_clear
		nop
		dla	$a0, bev0_handler
		jal	bev0_handler_install
		nop

		#
		# Uninterrupted access; check to make sure the right value
		# comes back.
		#
		ll	$a0, word
		sc	$a0, word
		lwu	$a1, word

		#
		# Load the word into another register between ll and sc; this
		# shouldn't cause the store to fail.
		#
		ll	$a2, word
		lwu	$t0, word
		sc	$a2, word

		#
		# Check to make sure we are allowed to increment the loaded
		# number, so we can do atomic arithmetic.
		#
		ll	$a3, word
		addiu	$a3, $a3, 1
		sc	$a3, word
		lwu	$a4, word

		#
		# Store to word between ll and sc; check to make sure that
		# the sc not only returns failure, but doesn't store.
		#
		li	$t0, 1
		ll	$a5, word
		sw	$a5, word
		sc	$t0, word
		lwu	$a6, word

		#
		# Trap between ll and sc; check to make sure that the sc not
		# only returns failure, but doesn't store.
		#
		ll	$a7, word
		tnei	$zero, 1
		sc	$a7, word

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test


#
# No-op exception handler to return back after the tnei and confirm that the
# following sc fails.  This code assumes that the trap isn't from a branch-
# delay slot.

#
		.ent bev0_handler
bev0_handler:
		mfc0	$k0, $14	# EPC
		daddiu	$k0, $k0, 4	# EPC += 4 to bump PC forward on ERET
		mtc0	$k0, $14
		nop			# NOPs to avoid hazard with ERET
		nop			# XXXRW: How many are actually
		nop			# required here?
		nop
		eret
		.end bev0_handler

		.data
word:		.word	0xffffffff
