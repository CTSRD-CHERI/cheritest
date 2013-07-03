.set mips64
.set noreorder
.set nobopt
.set noat

# Tests to exercise the division ALU instruction.

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
	    
        # Individual tests
        # START TEST
        
        mtc1 $0, $f31

        # DIV.D

        # Loading 3456.3
        add $s0, $0, $0
        ori $s0, $s0, 0x40AB
        dsll $s0, $s0, 16
        ori $s0, $s0, 0x0099
        dsll $s0, $s0, 16
        ori $s0, $s0, 0x9999
        dsll $s0, $s0, 16
        ori $s0, $s0, 0x999A
        dmtc1 $s0, $f0
        # Loading 12.45
        add $s0, $0, $0
        ori $s0, $s0, 0x4028
        dsll $s0, $s0, 16
        ori $s0, $s0, 0xE666
        dsll $s0, $s0, 16
        ori $s0, $s0, 0x6666
        dsll $s0, $s0, 16
        ori $s0, $s0, 0x6666
        dmtc1 $s0, $f1
        # Performing operation
        div.d $f0, $f0, $f1
        dmfc1 $s0, $f0
             
        # DIV.S
        lui $t0, 0x41A0     # 20.0
        mtc1 $t0, $f10
        lui $t0, 0x40A0     # 5.0
        mtc1 $t0, $f11
        div.S $f10, $f10, $f11
        mfc1 $s1, $f10
        
        # DIV.D (QNaN)
        lui $t2, 0x7FF1     # QNaN
        dsll $t2, $t2, 32
        dmtc1 $t2, $f13
        div.D $f13, $f13, $f13
        dmfc1 $s3, $f13
        
        # DIV.S (Denorm)
        lui $t0, 0x0100
        mtc1 $t0, $f31      # Enable flush to zero on denorm.
        lui $t0, 0x3F80     # 1.0
        mtc1 $t0, $f21
        lui $t1, 0x0001     # Some denormalised single
        mtc1 $t1, $f22
        div.S $f22, $f22, $f21
        mfc1 $s4, $f22

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
        
