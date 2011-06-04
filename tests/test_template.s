.set mips64
.set noreorder
.set nobopt
.set noat

#
# Comment about test goes here
#

		.global test
test:		.ent test
		addu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		addu	$fp, $sp, 32

		# Test itself goes here
		nop

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		addu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
