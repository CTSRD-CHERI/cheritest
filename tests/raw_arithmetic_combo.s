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
		move $a0, $0
		move $a1, $0
		addi $a0, $a0, -10
		addiu $a1, $a0, 30
		add  $a0, $a0, $a1
		addu $a1, $a1, $a0
		and $a1, $a1, $a0
		andi $a0, $a1, 2
		sll $a0, $a0, 4
		dsllv $a1, $a1, $a0
		dadd $a1, $a1, $a1
		daddi $a1, $a1, 20
		daddiu $a1, $a1, -10
		daddu $s0, $a1, $a1		# t0 = 0x2800000014
		sra $a0, $a0, 3
		ori $a0, $a0, 16
		ddiv $0, $s0, $a0
		mflo $a1
		srl $a0, $a0, 4
		ddivu $0, $a1, $a0
		mflo $a1
		div $0, $a1, $a0
		mflo $a1
		xori $a1, $a1, 40971
		xor $a0, $a0, $a1
		divu $0, $a0, $a1
		mflo $s1					# t1 = 0x0000000001
		dsll $a0, $s1, 20
		mult $a0, $a1
		mfhi $a0
		dsll32 $a0,$a0,20
		dmult $a0,$a1
		mfhi $a0
		sub $a0, $a0, $a1
		dmultu $a0, $a1
		mflo $s2					# t2 = 0xffffffff9c320384
		sub $a0, $0, $s2
		dsra $a1, $a1, 14
		dsll32 $a0, $a0, 1
		dsrav $a0, $a0, $a1
		dsra32 $a0, $a0, 4
		dsrl $a0, $a0, 4
		mul $a1, $a1, $a1
		dsrlv $s3, $a0, $a1		# t3 = 0x00FFFFFFFFFF1E6F
		dsll32 $a0, $s3, 4
		dsrl32 $a0, $a0, 4
		dsub $a1, $a0, $a1
		multu $a0, $a1
		mflo $a1
		mfhi $a0
		nor $a0, $a0, $a1
		or $s4, $a0, $a1			# t4 = 0xF..FFC3BE75
		dsubu $a0, $s4, $a1
		andi $a1, $a1, 4
		sllv $a0, $a0, $a1
		srav $a0, $a0, $a1
		srlv $a0, $a0, $a1
		subu $a0, $a0, $a1
		lui $a1, 3984
		addi $a1, $a1, 61
		subu $s5, $a0, $a1		# t5 = 0x0
		move $v0, $s5
		
		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	    mtc0 $v0, $23
end:
		b end
		.end	test
