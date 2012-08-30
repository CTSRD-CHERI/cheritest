.set mips64
.set noreorder
.set nobopt
.set noat

# Tests to exercise the comparison (unordered) ALU instructions.

        .text
        .global start
        .ent start
start:     
        # First enable CP1 
        dli $t1, 1 << 29
        or $at, $at, $t1    # Enable CP1    
	    mtc0 $at, $12 
	    
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
        or $t0, $t0, $t1
        dmtc1 $t0, $f23
        lui $t0, 0x3FF0
        dsll $t0, $t0, 32
        dmtc1 $t0, $f14
        ori $t1, $0, 0x4000
        dsll $t1, $t1, 16
        or $t0, $t0, $t1
        dmtc1 $t0, $f24

        # Individual tests
        
        # C.UN.S (True)
        lui $t0, 0x7F81     # QNaN
        mtc1 $t0, $f5
        c.un.S $f3, $f5
        cfc1 $s0, $f25
        
        # C.UN.D (True)
        lui $t0, 0x7FF1
        dsll $t0, $t0, 32   # QNaN
        dmtc1 $t0, $f15
        c.un.D $f15, $f15
        cfc1 $s1, $f25
        
        # C.UN.PS (True)
        c.un.PS $f5, $f5
        cfc1 $s2, $f25
        
        # C.UN.S (False)
        c.un.s $f3, $f3
        cfc1 $s3, $f25
        
        # C.UN.D (False)
        c.un.D $f13, $f14
        cfc1 $s4, $f25
        
        # C.UN.PS (False)
        c.un.PS $f24, $f23
        cfc1 $s5, $f25

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
