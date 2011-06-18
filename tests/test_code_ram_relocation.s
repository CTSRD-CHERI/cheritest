.set mips64
.set noreorder
.set nobopt
.set noat

#
# This tests that we can relocate code to the exception handler address in
# RAM, jump to it manually, and jump back.  This must work for our later
# exception handling tests to work.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Copy our stub handler to the RAM address for regular
		# exception handling.
		#
		dli	$a0, 0xffffffff80000180
		dla	$a1, handler
		dli	$a2, 8		# Number of instructions to copy
		dsll	$a2, $a2, 2	# Number of bytes to copy

		jal	memcpy
		nop			# branch-delay slot

		#
		# Jump to handler address
		#
jumpto:
		li	$t0, 1
		dli	$a0, 0xffffffff80000180

		jr	$a0
		nop			# branch-delay slot

back:
		li	$t2, 3

return:
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

#
# Position-independent "jump back" code.  Be careful not to let the size of
# this code get out of sync with the copying code above!
#
# XXXRW: Really, we should let the linker calculate the length for us.
#
handler:
		dla	$a0, back
		j	$a0
		li	$t1, 2		# branch-delay slot
