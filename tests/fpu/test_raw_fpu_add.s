.set mips64
.set noreorder
.set nobopt
.set noat

# Tests to exercise the addition ALU instruction.

        .text
        .global start
        .ent start
start:     
        # First enable CP1 
        dli $t1, 1 << 29
        or $at, $at, $t1    # Enable CP1    
	    mtc0 $at, $12 

        # Individual tests
        
        # ADD.D
        lui $t2, 0x3FF0
        dsll $t2, $t2, 32   # 1.0
        dmtc1 $t2, $f13
        add.D $f13, $f13, $f13
        dmfc1 $s0, $f13
        
        # ADD.S
        lui $t0, 0x3F80      # 1.0
        mtc1 $t0, $f14
        add.S $f14, $f14, $f14
        dmfc1 $s1, $f14
        
        # ADD.PS
        lui $t0, 0x3F80
        dsll $t0, $t0, 32   # 1.0
        ori $t1, $0, 0x4000
        dsll $t1, $t1, 16   # 2.0
        or $t0, $t0, $t1
        dmtc1 $t0, $f15
        add.PS $f15, $f15, $f15
        dmfc1 $s2, $f15
        
        # ADD.D (QNaN)
        lui $t2, 0x7FF1
        dsll $t2, $t2, 32   # QNaN
        dmtc1 $t2, $f13
        add.D $f13, $f13, $f13
        dmfc1 $s3, $f13
        
        # ADD.S (Denorm)
        lui $t0, 0x0100
        mtc1 $t0, $f31      # Enable flush to zero on denorm.
        lui $t1, 0x1
        dmtc1 $t1, $f22
        add.S $f22, $f22, $f22
        dmfc1 $s4, $f22        

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
