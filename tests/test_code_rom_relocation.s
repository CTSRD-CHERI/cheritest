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
		# Set up 'handler' as the ROM exception handler.
		#
		dli	$a0, 0xffffffffbfc00380
		dla	$a1, handler
		jal	handler_install
		nop

		#
		# Jump to handler address
		#
		li	$t0, 1
		dli	$a0, 0xffffffffbfc00380
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

handler:
		dla	$a0, back
		j	$a0
		li	$t1, 2		# branch-delay slot
