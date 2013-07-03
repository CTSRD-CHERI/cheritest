.set mips64
.set noreorder
.set nobopt
.set noat

# Tests to exercise the comparison (less than) ALU instructions.

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
        nop    
    
	    # Setup parameters
	    
	    mtc1 $0, $f31
        lui $t0, 0x4000     # 2.0
        mtc1 $t0, $f3
        lui $t0, 0x3F80     # 1.0
        mtc1 $t0, $f4
        lui $t0, 0x4000     
        dsll $t0, $t0, 32
        dmtc1 $t0, $f13
        ori $t1, $0, 0x3F80
        dsll $t1, $t1, 16
        or $t0, $t0, $t1    # 2.0, 1.0
        dmtc1 $t0, $f23
        lui $t0, 0x3FF0
        dsll $t0, $t0, 32
        dmtc1 $t0, $f14
        ori $t1, $0, 0x4000
        dsll $t1, $t1, 16
        or $t0, $t0, $t1    # 1.0, 2.0
        dmtc1 $t0, $f24

        # Individual tests
        
        # C.OLT.S (True)
        c.olt.S $f4, $f3
        cfc1 $s0, $f25
        
        # C.OLT.D (True)
        c.olt.D $f14, $f13
        cfc1 $s1, $f25
        
        # C.OLT.PS
        c.olt.PS $f23, $f24
        cfc1 $s2, $f25
        
        # C.OLT.S (False)
        c.olt.S $f3, $f3
        cfc1 $s3, $f25
        
        # C.OLT.D
        c.olt.D $f13, $f13
        cfc1 $s4, $f25
        
        # C.OLT.PS
        c.olt.PS $f23, $f23
        cfc1 $s5, $f25

        # -0.8 < 1.0
        li $t0, 0xBF4CCCCC # 0.8
        li $t1, 0x3F800000 # 1.0
        mtc1 $t0, $f0
        mtc1 $t1, $f1
        ctc1 $0, $f31 # clear condition codes

        c.olt.S $f0, $f1
        cfc1 $s6, $f25
        
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
