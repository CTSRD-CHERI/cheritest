.set mips64
.set noreorder
.set nobopt
.set noat

# Tests to exercise the multiplication ALU instruction.

        .text
        .global start
        .ent start
start:     
        # First enable CP1 
        dli $t1, 1 << 29
        or $at, $at, $t1    # Enable CP1    
	    mtc0 $at, $12 

        # Individual tests
        
        # MUL.D
        lui $t3, 0x4000
        dsll $t3, $t3, 32   # 2.0
        dmtc1 $t3, $f29
        mul.D $f27, $f29, $f29
        dmfc1 $s0, $f27
        
        # MUL.S
        lui $t2, 0x4080     # 4.0
        mtc1 $t2, $f20
        mul.S $f20, $f20, $f20
        dmfc1 $s1, $f20
        
        # MUL.PS
        lui $t0, 0x4040
        dsll $t0, $t0, 32   # 0.5
        ori $t1, $0, 0xBF80
        dsll $t1, $t1, 16   # -1.0
        or $t0, $t0, $t1
        dmtc1 $t0, $f20
        lui $t0, 0x40A0
        dsll $t0, $t0, 32   # 5.0
        ori $t1, $0, 0xBF80
        dsll $t1, $t1, 16
        or $t0, $t0, $t1
        dmtc1 $t0, $f1
        mul.PS $f6, $f1, $f20
        dmfc1 $s2, $f6
        
        # MUL.PS (QNaN)
        lui $t2, 0x7F81
        dsll $t2, $t2, 32   # QNaN
        ori $t1, $0, 0x4000
        dsll $t1, $t1, 16   # 2.0
        or $t2, $t2, $t1
        dmtc1 $t2, $f13
        mul.PS $f13, $f13, $f13
        dmfc1 $s3, $f13
        
        # MUL.S (Denorm)
        lui $t0, 0x0100
        mtc1 $t0, $f31      # Enable flush to zero on denorm.
        lui $t1, 0x1
        dmtc1 $t1, $f22
        mul.S $f22, $f22, $f22
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
