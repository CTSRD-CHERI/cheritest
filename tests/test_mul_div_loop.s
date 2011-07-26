.set mips64
.set noreorder
.set nobopt
.set noat

#
# This test runs a loop of multiplying and dividing
# numbers with a seed from -10 to 10.  We just test
# that the final results are correct.
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
		move	$t8,$v0
skip_div:
		addiu	$s1,$s1,1
    move	$v1,$v0
		movz	$v1,$s6,$v0
		sw	$v1,0($sp)
		slti	$v0,$s1,10
		bnez	$v0, loop
		lw	$s2,0($sp)
end:
		jr	$ra
		nop			# branch-delay slot
		.end	test
