.set mips64
.set noreorder
.set nobopt
.set noat

# Tests to exercise the absolute value ALU instruction.

        .text
        .global start
        .ent start
start:     
        # First enable CP1 
        dli $t1, 1 << 29
        or $at, $at, $t1    # Enable CP1    
	    mtc0 $at, $12 

        # Individual tests
        
        # ABS.D
        lui $t0, 0x87FF     # Some double
        dsll $t0, $t0, 32
        dmtc1 $t0, $f11
        abs.D $f11, $f11
        dmfc1 $s0, $f11
        
        # ABS.S
        lui $t0, 0x8FFF     # Some single
        mtc1 $t0, $f12
        abs.S $f12, $f12
        mfc1 $s1, $f12
        
        # ABS.PS
        lui $t0, 0xBF80
        dsll $t0, $t0, 32   # -1.0
        ori $t1, $0, 0x4000
        dsll $t1, $t1, 16   # 2.0
        or $t0, $t0, $t1
        dmtc1 $t0, $f15
        abs.PS $f15, $f15
        dmfc1 $s2, $f15
        
        # ABS.PS (QNaN)
        lui $t2, 0x7F81
        dsll $t2, $t2, 32   # QNaN
        ori $t1, $0, 0x4000
        dsll $t1, $t1, 16   # 2.0
        or $t2, $t2, $t1
        dmtc1 $t2, $f13
        abs.PS $f13, $f13
        dmfc1 $s3, $f13
        
        # ABS.S (Denorm)
        lui $t0, 0x0100
        mtc1 $t0, $f31      # Enable flush to zero on denorm.
        lui $t1, 0x1
        dmtc1 $t1, $f22
        abs.S $f22, $f22
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
