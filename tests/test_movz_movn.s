.set mips64
.set noreorder
.set nobopt
.set noat

#
# This test exercises movz and movn in true and false
# cases for each.  They take operands fed from preceding
# loads and feed into stores.  This case failed in compiled
# code due to movz and movn being a special case for
# pipeline forwarding.
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
