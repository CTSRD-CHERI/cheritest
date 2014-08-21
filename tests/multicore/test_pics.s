#-
# Copyright (c) 2012 Robert M. Norton
# Copyright (c) 2014 Michael Roe
# All rights reserved.
#
# @BERI_LICENSE_HEADER_START@
#
# Licensed to BERI Open Systems C.I.C. (BERI) under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  BERI licenses this
# file to you under the BERI Hardware-Software License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at:
#
#   http://www.beri-open-systems.org/legal/license-1-0.txt
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @BERI_LICENSE_HEADER_END@
#

# Multi-threaded test for inter-thread interrupts via the PIC.
# Thread 0 sends an interrupt to thread 1, which sends an interrupt
# to thread 0 in return.

.include "macros.s"
        
.set mips64
.set noreorder
.set nobopt

.global test
test:   .ent    test
	daddu 	$sp, $sp, -32
	sd	$ra, 24($sp)
	sd	$fp, 16($sp)
	daddu	$fp, $sp, 32


	#
        # Enable interrupts
	#

        mfc0    $t0, $12	# get status register
        ori	$t0, $t0, 0xc01	# unmask interrupt 0/1 and enable interrupts
        # and     $t0, ~0x6	# clear ERL, EXL (not needed)
        mtc0    $t0, $12	# set status register
        
	mfc0	$v0, $15, 6	# CoreId
	andi	$v0, $v0, 0xffff
        bnez    $v0, core1
        nop

	#
	# Only core 0 runs this part
	#

core0:
	#
        # Activate core 1
	#

        jal     other_threads_go
        nop

	#
	# Set up exception handlers.
	#

	jal	bev_clear
	nop

	#
        # Handler for core 0
	#

        dla	$a0, bev0_handler
	jal	bev0_handler_install
	nop

	#
        # Handler for core 1 -- note that we don't clear bev for core 1
        # so we have a handler for each core
	#

	dla	$a0, bev1_handler
	jal	bev1_handler_install
	nop

	#
        # Configure the PIC
	# Enable interrupt 3 and forward to thread 0 irq 1
	#

        dla     $s7, 0x900000007f804000	# Base address of PIC 0
        dli     $t0, 0x80000001		# IRQ 1
        sd      $t0, 24($s7)     	# Interrupt source 3 (3*8 = 24)


	#
        # Synchronise with core 1
	#

        dla    $a0, my_barrier
        jal    thread_barrier
	nop

        # A small loop to ensure core 1 has had time to reach expected_epc
        li      $t0, 100
1:      
        bgtz    $t0, 1b
        subu    $t0, 1

	#
        # Trigger interrupt 2 on core 1
	#

        dli     $t0, 0x4	# Interupt source 2 (4 = 1 << 2)
	# PIC_IP_SET_BASE = PIC_CONFIG_BASE + 8*1024 + 128
	# Add another 0x4000 to get to PIC1 from PIC0
        sd      $t0, 0x6080($s7) 

expected_epc0:
        b      .              # wait to be interrupted
        mfc0   $a2, $13       # read cause (for debugging)
        
the_end:
        dla    $s2, expected_epc0
        dla    $s3, expected_epc1
        
        dla    $a0, my_barrier
        jal    thread_barrier
        nop

	mtc0    $0, $26
	
	ld	$fp, 16($sp)
	ld	$ra, 24($sp)
	jr      $ra
	daddu	$sp, $sp, 32
.end    test
	
core1:
        dla     $s7, 0x900000007f808000	# Base address of PIC 1
        dli     $t0, 0x80000000
        sd      $t0, 16($s7)     # enable int 2 and forward to thread 0 irq 0

        # Synchronise with core 0
        dla    $a0, my_barrier
        jal    thread_barrier
        nop

expected_epc1:
        b      .              # wait to be interrupted
        mfc0   $a2, $13       # read cause (for debugging)

after_interrupt_t1:
        li     $t0, 8
        sd     $t0, 8320($s7) # Trigger int 3 -> core 0
        
        j      the_end
        nop

#
# Exception handlers
#
        .ent bev0_handler
bev0_handler:	
	dmfc0	$s0, $13	# Cause register
	dmfc0	$s1, $14	# EPC
	        
        b       the_end
        nop
	.end bev0_handler
        
	.ent bev1_handler
bev1_handler:	
	dmfc0	$s0, $13	# Cause register
	dmfc0	$s1, $14	# EPC
	        
        b       after_interrupt_t1
        nop
	.end bev1_handler

.data
my_barrier:
        mkBarrier
