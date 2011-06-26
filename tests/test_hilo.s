.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test for 'HI' and 'LO' registers used with integer multiply and divide.  The
# goal of this test is to make sure that data flow in and out of the registers
# is working as intended, not to fully exercise multiply or divide.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Check that HI and LO are initialised to 0 on reset.
		#
		mfhi	$a0
		mflo	$a1

		# Mandated double-nop between reads and writes
		nop
		nop

		#
		# Check that we can load values into, and extract values out
		# of HI and LO for context switching purposes.
		#
		dli	$t0, 0xe624379d7daf6318
		mthi	$t0
		dli	$t1, 0x608467ffc8a78552
		mtlo	$t1

		# Mandated double-nop between reads and writes
		nop
		nop

		mfhi	$a2
		mflo	$a3

		#
		# Do a single multiply operation.  We are interested only in
		# whether an answer pops out in the registers.
		#
		dli	$t0, 0x4c1de53737a475d3
		dli	$t1, 0x0ed59e2102fc6a4e
		dmult	$t0, $t1

		# Mandated double-nop between reads and writes
		nop
		nop

		mfhi	$a4
		mflo	$a5

		#
		# And likewise, a single divide operation.
		#
		dli	$t1, 0x5568a2865eb2ee3e
		dli	$t0, 0x2ac0abc68a41800e
		ddiv	$t0, $t1

		# Mandated double-nop between reads and writes
		nop
		nop

		mfhi	$a6
		mflo	$a7

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
