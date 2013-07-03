.set mips64
.set noreorder
.set nobopt
.set noat

# Tests to ensure branching works as expected

        .text
        .global start
        .ent start
start:     
        # First enable CP1 
        dli $t1, 1 << 29
        or $at, $at, $t1   # Enable CP1    
	    mtc0    $at, $12 
        nop
        nop
        nop
        nop

        li $s1, 0x1111
        li $s2, 0x1111
        li $s3, 0x1111
        li $s4, 0x1111
        li $t1, 0xDEAD

        # CCs should be 0
        movf $s1, $t1, $fcc0
        movt $s2, $t1, $fcc0

        li $t0, 1
        ctc1 $t0, $f25 # Set cc[0]=1

        movf $s3, $t1, $fcc0
        movt $s4, $t1, $fcc0

end_test:
        # Dump registers on the simulator (gxemul dumps regs on exit)
		mtc0 $at, $26
		nop
		nop

		# Terminate the simulator
		mtc0 $at, $23
end:
		b end
		nop
		.end start
