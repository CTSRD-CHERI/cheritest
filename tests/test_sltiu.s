.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test sltiu (set on less than immediate unsigned)
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		dli	$t0, 1
		dli	$t1, -1
		dli	$t2, -2
		dli	$t3, 0x10000

		# Equal, non-negative
		sltiu	$a0, $zero, 0

		# Greater than, non-negative
		sltiu	$a1, $t0, 0

		# Less than, non-negative
		sltiu	$a2, $zero, 1

		# sltiu sign extends its immediate, so this should be true:
		sltiu	$a3, $t3, 0xffff

		# sltiu does an unsigned comparision, so this should be false
		sltiu	$a4, $t1, 0

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
