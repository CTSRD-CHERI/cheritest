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

		#
		# Setup one stack per core
		#
                mfc0 $k0, $12 
                li $k1, 0xF0000000 
                or $k0, $k0, $k1  
                mtc0 $k0, $12
                dla $sp, __sp
                mfc0    $t0, $15, 1 
                andi    $t0, $t0, 0xFFFF 
                dli     $k0, 0x400  
                mul     $k0, $k0, $t0
                daddu   $sp, $sp, $k0 
                daddu   $sp, $sp, -64 
                beqz    $t0, pic1 
                nop 

start:		
		nop
pic0:
		#
		# PIC 0 Test
		#
	        dla     $a0, 0x900000007f804000  # PIC_BASE 
   	 	dla     $t0, 0x80000004          # enable irq 2, forward to IP4 
  	 	sd      $t0, 16($a0)         
	        dadd    $a1, $a0, 0x2000         # PIC_IP_READ_BASE 
	        li      $t0, 6                            
	        sd      $t0, 128($a1)            # set irq 2 and 1 
	        ld      $a2, 0($a1)              # read irq pending 
		dmfc0   $a3, $13                 # read cause reg    
		sd      $t0, 256($a1)            # clear irq 2   
		ld      $a4, 0($a1)              # read irq pending  
		j       dump
		nop

pic1:
		nop
		#
		# PIC 1 Test
		#
	        dla     $a0, 0x900000007f808000  # PIC_BASE 
   	 	dla     $t0, 0x80000004          # enable irq 2, forward to IP4 
  	 	sd      $t0, 16($a0)         
	        dadd    $a1, $a0, 0x2000         # PIC_IP_READ_BASE 
	        li      $t0, 6                            
	        sd      $t0, 128($a1)            # set irq 2 and 1 
	        ld      $a2, 0($a1)              # read irq pending 
		dmfc0   $a3, $13                 # read cause reg    
		sd      $t0, 256($a1)            # clear irq 2   
		ld      $a4, 0($a1)              # read irq pending  
		j 	dump
		nop

dump:
		# Dump registers in the simulator
		mtc0    $v0, $26 
		nop
		nop                

                # Terminate the simulator 
                mtc0    $v0, $23 

end:
		b       end
		nop
