.set mips64
.set noreorder
.set nobopt
.set noat

# Tests to exercise the pairwise merging instructions.

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
        nop

        # Individual tests
        
        # PLL.PS
        lui $t0, 0x3F80
        mtc1 $t0, $f7
        lui $t0, 0x4000
        mtc1 $t0, $f8
        pll.PS $f7, $f7, $f8
        dmfc1 $a0, $f7
        
        # PLU.PS
        lui $t0, 0xBF80
        mtc1 $t0, $f13
        lui $t0, 0x3F80
        dsll $t0, $t0, 32
        dmtc1 $t0, $f23
        plu.PS $f14, $f13, $f23
        dmfc1 $a1, $f14
        
        # PUL.PS
        lui $t0, 0x7F80
        dsll $t0, $t0, 32
        dmtc1 $t0, $f5
        mtc1 $0, $f6
        pul.PS $f5, $f5, $f6
        dmfc1 $a2, $f5
        
        # PUU.PS
        puu.PS $f5, $f5, $f23
        dmfc1 $a3, $f5
        
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
        
        
