.set mips64
.set noreorder
.set nobopt
.set noat

# Tests to exercise the reciprocal square root ALU instruction.

        .text
        .global start
        .ent start
start:     
        # First enable CP1 
        dli $t1, 1 << 29
        or $at, $at, $t1    # Enable CP1    
	    mtc0 $at, $12 
        nop
        nop
        nop
        nop

        # Individual tests
        # START TEST

        # RECIP.D
        lui $t0, 0x4030
        dsll $t0, $t0, 32   # 16.0
        dmtc1 $t0, $f19
        recip.D $f19, $f19
        dmfc1 $s0, $f19
        
        # RECIP.S
        mtc1 $0, $f19       # 0.0
        recip.S $f19, $f19
        mfc1 $s1, $f19
        
        # RECIP.D (QNaN)
        lui $t2, 0x7FF1
        dsll $t2, $t2, 32   # QNaN
        dmtc1 $t2, $f13
        recip.D $f13, $f13
        dmfc1 $s3, $f13
        
        # RECIP.S (Denorm)
        lui $t0, 0x0100
        ctc1 $t0, $f31      # Enable flush to zero on denorm.
        lui $t0, 0x7F7F     # Some single greater than 2^(e_max-1)
        mtc1 $t0, $f7

        # END TEST
        
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
            
        
        
