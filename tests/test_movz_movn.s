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
movz_false:
    li	$a0,1
    li	$a1,-1
    sw	$a1,0($sp)
    lw	$v0,0($sp)
    lw	$v1,0($sp)
    movz	$v1,$a0,$v0
    sw	$v1,0($sp)
    lw	$s0,0($sp)
movz_true:
    sw	$a1,0($sp)
    lw	$v0,0($sp)
    lw	$v1,0($sp)
    movz	$v1,$a0,$zero
    sw	$v1,0($sp)
    lw	$s1,0($sp)
movn_false:
    sw	$a1,0($sp)
    lw	$v0,0($sp)
    lw	$v1,0($sp)
    movn	$v1,$a0,$a0
    sw	$v1,0($sp)
    lw	$s2,0($sp)
movn_true:
    sw	$a1,0($sp)
    lw	$v0,0($sp)
    lw	$v1,0($sp)
    movn	$v1,$a0,$v1
    sw	$v1,0($sp)
    lw	$s3,0($sp)
end:
		jr	$ra
		nop			# branch-delay slot
		.end	test
