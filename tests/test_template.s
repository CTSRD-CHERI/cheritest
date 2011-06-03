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
		sw	$ra, 24($sp)
		sw	$fp, 16($sp)
		addu	$fp, $sp, 32

		# Test itself goes here
		nop

		lw	$fp, 16($sp)
		lw	$ra, 24($sp)
		addu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
