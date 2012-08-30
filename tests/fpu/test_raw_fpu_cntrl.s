.set mips64
.set noreorder
.set nobopt
.set noat

# Tests to exercise the MOV instructions for moving values between general purpose 
# and floating point (COP1) registers.

        .text
        .global start
        .ent start
start:     
        # First enable CP1 
        dli $t1, 1 << 29
        or $at, $at, $t1   # Enable CP1    
	    mtc0    $at, $12 
	    
	    # Individual tests
	    
        # MTC / MFC
        li $t0, 9
        mtc1 $t0, $f1
        mfc1 $s0, $f1
        
        # DMTC / DMFC
        lui $t0, 18
        dsll $t0, $t0, 16
        ori $t0, 7
        dmtc1 $t0, $f5
        dmfc1 $s1, $f5
        
        # CTC / CFC
        li $t0, 0xFFF3F
        ctc1 $t0, $f25
        cfc1 $s2, $f25
        
        li $t0, 0xFFF1
        ctc1 $t0, $f26
        cfc1 $s3, $f26
        
        li $t0, 0xFFF86
        ctc1 $t0, $f28
        cfc1 $s4, $f28
        
        li $t0, 0x0003FFFF
        ctc1 $t0, $f31
        cfc1 $s5, $f31
        
        cfc1 $s6, $f28
        
        cfc1 $s7, $f26
        
        cfc1 $a0, $f25
        
        # MOV.S
        lui $t1, 0x4100
        mtc1 $t1, $f4
        mov.S $f3, $f4
        mfc1 $t8, $f3
        
        # MOV.D
        lui $t2, 0x4000
        dsll $t2, $t2, 32
        dmtc1 $t2, $f7
        mov.D $f3, $f7
        dmfc1 $t3, $f3
        
        # MOV.PS
        or $t0, $t1, $t2
        dmtc1 $t0, $f5
        mov.PS $f3, $f5
        dmfc1 $t2, $f3 

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
