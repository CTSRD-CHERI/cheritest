.set mips64
.set noreorder
.set nobopt
.set noat

#
# This test simply loads 32-bit and 64-bit constants into $t0 and $t1.
#

		.global	test
test:		.ent	test
		addu 	$sp, $sp, -32

		li	$t0, 0x76543210
		dli	$t1, 0xfedcba9876543210

		addu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
