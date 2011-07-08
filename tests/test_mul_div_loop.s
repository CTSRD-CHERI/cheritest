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
		li	$s2,1
		li	$s1,-10
		li	$s6,1
loop:
		mul	$v0,$s2,$s1
		sw	$v0,0($sp)
		beqz	$s1, skip_div
		lw	$v0,0($sp)
		move	$s7,$v0
		div	$0,$v0,$s1
		teq	$s1,$0,0x7
		mflo	$v0
		move	$s8,$v0
skip_div:
		addiu	$s1,$s1,1
		movz	$v1,$s6,$v0
		sw	$v1,0($sp)
		slti	$v0,$s1,10
		bnez	$v0, loop
		lw	$s2,0($sp)
end:
		jr	$ra
		nop			# branch-delay slot
		.end	test
