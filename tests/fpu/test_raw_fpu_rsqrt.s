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

        # Individual tests
        
        # RSQRT.S
        lui $t0, 0x4080     # 4.0
        mtc1 $t0, $f23
        rsqrt.S $f22, $f23
        mfc1 $s0, $f22
        
        # RSQRT.D
        dmtc1 $0, $f3       # 0.0
        rsqrt.D $f3, $f3
        dmfc1 $s1, $f3
        
        # RSQRT.D (QNaN)
        lui $t2, 0x7FF1
        dsll $t2, $t2, 32   # QNaN
        dmtc1 $t2, $f13
        rsqrt.D $f13, $f13
        dmfc1 $s3, $f13
        
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
