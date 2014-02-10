#-
# Copyright (c) 2013 Alan A. Mujumdar
# Copyright (c) 2011 Robert N. M. Watson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract (FA8750-10-C-0237)
# ("CTSRD"), as part of the DARPA CRASH research programme.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

.set mips64
.set noreorder
.set nobopt
.set noat

#
# Exercise cache instructions
#
# Execute a series of cache instructions that are found in the kernel.  We
# currently don't check if they are correct, but merely check that they don't
# lock up the processor.  Since we have a write-through L1 cache, the only 
# function of the cache instructions is to synchronize L1 instruction and data
# caches.  We don't currently support cache instructions to the L2.
# 
#

		.global start
start:
		#
		# Setup Stack
		#
		mfc0    $k0, $12
		li      $k1, 0xF0000000 
		or      $k0, $k0, $k1 
		mtc0    $k0, $12 
		dla     $sp, __sp
		mfc0    $t0, $15, 1
		andi    $t0, $t0, 0xFFFF
		dli     $k0, 0x400  
		mul     $k0, $k0, $t0    
		daddu   $sp, $sp, $k0
		daddu   $sp, $sp, -64 
		
		bnez    $t0, core_1_wait
		nop
		j       core_0_wait 
		nop   

# Ensure that both cores have completed the stack setup and are in sync                
core_0_wait:
                addi    $t1, $zero, 1234
                dli     $t2, 0x9800000000001110
                dli     $t3, 0x9800000000001114 
                sw      $t1, 0($t2)
                lw      $t1, 0($t3)
                bnez    $t1, core_0
                nop
                j       core_0_wait
                nop

core_1_wait:
                addi    $t1, $zero, 1234
                dli     $t2, 0x9800000000001114
                dli     $t3, 0x9800000000001110 
                sw      $t1, 0($t2)
                lw      $t1, 0($t3)
                bnez    $t1, core_1
                nop
                j       core_1_wait
                nop

# Core 0 sets initial values (zero's) in two memory location (x and y)
# Each memory location is then changed to 1's in the order x then y
core_0:
                dli     $t3, 0x9800000000001120
                dli     $a4, 0x9800000000001124
                addi    $t1, $zero, 0
                sw      $t1, 0($t3)
                addi    $t2, $zero, 0
                sw      $t2, 0($a4)
                addi    $t1, $t1, 1
                sw      $t1, 0($t3)
                addi    $t2, $t2, 1
                sw      $t2, 0($a4)
		j       core_0_finish
		nop		

# Core 1 checks memory location y to see if its init value has been changed
# If it has then memory location x is read
# If x is still zero then this is a serious coherence failure
core_1:		
	        dli     $t3, 0x9800000000001120
                dli     $a4, 0x9800000000001124
                lw      $t2, 0($a4)
		beqz    $t2, core_1
                lw      $a0, 0($t3)	
		j       core_1_finish
		nop

# Ensure that both cores have completed running the test
core_0_finish:
                dli     $t2, 0x9800000000001130
                dli     $t3, 0x9800000000001134
                addi    $a4, $zero, 1
                sw      $a4, 0($t3)
                lw      $t1, 0($t2)
                beqz    $t1, core_0_finish
                nop
                j       finish
                nop

core_1_finish:
                dli     $t2, 0x9800000000001130
                dli     $t3, 0x9800000000001134
                addi    $a4, $zero, 1
                sw      $a4, 0($t2)
                lw      $t1, 0($t3)
                beqz    $t1, core_1_finish
                nop
                j       finish
                nop

finish:
		# Dump registers in the simulator
		mtc0    $v0, $26 
		nop
		nop                

                # Terminate the simulator 
                # many nop's are needed to ensure that both cores have enough
                # time to dump the register file. From experiments its clear
                # that even when cores in sync, one of them will kill the 
                # simulator before the second one has had a chance to finish
                # the dump 
                nop
                nop 
                nop
                nop 
                nop
                nop 
                nop
                nop 
                nop
                nop 
                nop
                nop 
                nop
                nop 
                nop
                nop 
                nop
                nop 
                nop
                nop 
                nop
                nop 
                nop
                nop 

                mtc0    $v0, $23 

end:
		b       end
		nop
