.set mips64
.set noreorder
.set nobopt

#
# Test which tries the 64-bit doubleword division unsigned operator with
# each combination of positive and negative arguments.
# Results are stored in hi (remainder) and lo (quotient)
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		# Test itself goes here
		dli	$t0, 0x0fedcba987654321
		dli	$t1, 0x0101010101010101 
		#$zero prevents assembler adding checking instructions
		ddivu	$zero, $t0, $t1
		mfhi	$a0
		mflo	$a1

		dli	$t0, 0xf0123456789abcdf
		dli	$t1, 0xfefefefefefefeff
		ddivu	$zero, $t0, $t1
		mfhi	$a2
		mflo	$a3

		dli	$t0, 0xf0123456789abcdf
		dli	$t1, 0x0101010101010101 
		ddivu	$zero, $t0, $t1
		mfhi	$a4
		mflo	$a5

		dli	$t0, 0x0fedcba987654321
		dli	$t1, 0xfefefefefefefeff
		ddivu	$zero, $t0, $t1
		mfhi	$a6
		mflo	$a7

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
