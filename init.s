#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2012 David T. Chisnall
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
# ("CTSRD"), as part of the DARPA CRASH research programme.
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

.include "macros.s"
        
.set mips64
.set noreorder
.set nobopt
.set noat

#
# Generic init.s used by low-level CHERI regression tests.  Set up a stack
# using memory set aside by the linker, and allocate an initial 32-byte stack
# frame (the minimum in the MIPS ABI).  Install some default exception
# handlers so we can try and provide a register dump even if things go
# horribly wrong during the test.
#

		.text
		.global start
		.ent start
start:

		#
		# Set CP0.Config.K0, the kseg0 coherency algorithm
		# We have to do this before we refer to kseg0
		#

	        mfc0    $t0, $16
       		ori     $t0, $t0, 7
		xori    $t0, $t0, 4 # Set to Cached.
        	mtc0    $t0, $16

                jal     get_corethread_id   # v0 = core ID * num threads + thread ID
                nop                         # (delay slot)

#continue:                 
		# Set up stack and stack frame
		dla	$fp, __sp
                sll     $t0, $v0, 10 # Allocate 1k stack per thread. XXX need to fix __heap_top__
                dsubu   $fp, $t0
		daddu 	$sp, $fp, -32
/*
		mfc0    $t0, $15, 1
		andi    $t0, $t0, 0xFFFF
		dli     $k0, 0x400  
		mul     $k0, $k0, $t0  
		daddu   $sp, $sp, $k0  
		daddu   $sp, $sp, -64       
		nop  
*/        
                dla     $a0, reset_barrier
                dla     $ra, all_threads    # cheeky tail call to skip exception handler install on non-zero threads
                bgtz    $v0, thread_barrier # enter barrier and spin if not thread 0
                nop

                # Thread 0 Code
		# FIXME: we don't always want this handler
		#
		# Install BEV0 exception handlers
		#

		# XXXAR: this is the old handler which is not great (but unlike the new one it clears timer interrupts)
		# dla	$a0, exception_count_handler
		# jal 	bev0_handler_install
		# nop

		# Install the new exception count handler:
		set_mips_common_bev0_handler jump_to_real_trap_handler
		__set_counting_trap_handler_count $zero


		#
		# Enable the BEV0 handlers
		#

		jal	bev_clear
		nop

.ifdef OLD_ZEROBSS
zero_bss:
		dla     $t0, __bss_start
		dla     $t1, __bss_end
1:
		beq     $t0, $t1, 2f # exit loop if finished
		nop
		sb      $0, 0($t0)
		b       1b
		dadd    $t0, $t0, 1
2:
.else
		dla $a0, __bss_start
		dla $a1, __bss_end
		dsubu $a1, $a1, $a0
		jal bzero
		nop			# Branch delay slot
.endif

all_threads:
	        mfc0    $at, $12
	        # Enable 64-bit mode (KX, SX)
		# (no effect on cheri, but required for gxemul)
	        or      $at, $at, 0xe0
	        # Enable timer interrupts (IM7, IE)
	        or      $at, $at, (1 << 15)
	        or      $at, $at, 1
		# Enable CP1 and CP2
                dli	$t1, 3 << 29
                or      $at, $at, $t1 
		# Clear ERL
		dli	$t1, 0x4
		nor	$t1, $t1, $t1
		and	$at, $at, $t1
	        # Clear pending timer interrupts before we enable them
	        mtc0    $zero, $11
	        mtc0    $at, $12

		mfc0	$t0, $16, 1	# Config1
		andi	$t1, $t0, 0x1	# FP
		beqz	$t1, no_float
		nop
		# Put FPU into 64 bit mode
		mfc0	$t0, $12
		dli	$t1, 1 << 26
		or	$t0, $t0, $t1
		mtc0	$t0, $12
		
no_float:

.ifdef BUILDING_PURECAP
# .global crt_init_globals

		# remove the Permit_Execute permission from DDC to catch more errors
		dli	$at, ~(CHERI_PERM_EXECUTE) # All but Permit_Execute
		cgetdefault	$c1
		candperm	$c1, $c1, $at
		csetdefault	$c1

		# When building for purecap (and potentially also hybrid) we
		# need to call crt_init_globals() before starting the test
		cfromptr	$c11, $c1, $sp
.ifdef __CHERI_CAPABILITY_TABLE__
		# If we are using the capability table we also need to setup $cgp
		dla $at, _CHERI_CAPABILITY_TABLE_
		# TODO: should this be a setoffset instead of cfromptr to have a
		# tagged $cgp even if the capability table is empty?
		cfromptr $cgp, $c1, $at
		# FIXME: we also wan't to set sensible bounds here and reduce permissions
.endif
		# clear  Permit_Store + Permit_StoreCapability on $c12 + $c17
		dli	$at, ~(CHERI_PERM_STORE | CHERI_PERM_STORE_CAP)
		cgetpcc	$c12
		# jump forward 4 instrs afters the cgetpcc to clear permissions from pcc
		cincoffset	$c12, $c12, 16
		candperm	$c12, $c12, $at
		cjr	$c12
		nop			# the cjr jumps here
		# Now PCC should no longer have permit_store/permit_store_capability

		dla	$t9, crt_init_globals
		cgetpccsetoffset $c12, $t9	# Call crt_init_globals
		cjalr	$c12, $c17
		nop

		# ensure all unused capability registers are NULL
		cclearlo 0xf7fe                         # clear c1-c10 & c12-c15
.ifdef __CHERI_CAPABILITY_TABLE__
		cclearhi 0x03ff                         # clear c16-c25
.else
		cclearhi 0x07ff                         # clear c16-c26
.endif # __CHERI_CAPABILITY_TABLE__
.endif # BUILDING_PURECAP

		#
		# Explicitly initialise most registers in order to make the effects
		# of a test on the register file more clear.  Otherwise,
		# values leaked from init.s and its dependencies may hang
		# around.
		#
		dli	$at, 0x0101010101010101 # r1 
		dli	$v0, 0x0202020202020202 # r2 
		dli	$v1, 0x0303030303030303 # r3 
		dli	$a0, 0x0404040404040404 # r4 
		dli	$a1, 0x0505050505050505 # r5 
		dli	$a2, 0x0606060606060606 # r6 
		dli	$a3, 0x0707070707070707 # r7 
		dli	$a4, 0x0808080808080808 # r8 
		dli	$a5, 0x0909090909090909 # r9 
		dli	$a6, 0x0a0a0a0a0a0a0a0a # r10
		dli	$a7, 0x0b0b0b0b0b0b0b0b # r11
		dli	$t0, 0x0c0c0c0c0c0c0c0c # r12
		dli	$t1, 0x0d0d0d0d0d0d0d0d # r13
		dli	$t2, 0x0e0e0e0e0e0e0e0e # r14
		dli	$t3, 0x0f0f0f0f0f0f0f0f # r15
		dli	$s0, 0x1010101010101010 # r16
		dli	$s1, 0x1111111111111111 # r17
		dli	$s2, 0x1212121212121212 # r18
		dli	$s3, 0x1313131313131313 # r19
		dli	$s4, 0x1414141414141414 # r20
		dli	$s5, 0x1515151515151515 # r21
		dli	$s6, 0x1616161616161616 # r22
		dli	$s7, 0x1717171717171717 # r23
		dli	$t8, 0x1818181818181818 # r24
		dli	$t9, 0x1919191919191919 # r25
		dli	$k0, 0x1a1a1a1a1a1a1a1a # r26
		dli	$k1, 0x1b1b1b1b1b1b1b1b # r27
		dli	$gp, 0x1c1c1c1c1c1c1c1c # r28
		# Not cleared: $sp, $fp, $ra
		mthi	$at
		mtlo	$at
		
		# Invoke test function test() provided by individual tests.
		dla   $25, test
		
		mfc0 $k0, $16, 1	# config1 register
		andi $k0, $k0, 0x40	# CP2 available bit

		ori $0, $0, 0xbeef	# start tracing on QEMU

		beqz $k0, skip_cp2_setup 
		nop

		cgetpccsetoffset $c12, $t9
		jalr $25
		cgetpccsetoffset $c17, $ra			# return address

.end start

		# Dump capability registers in the simulator
		#
.global finish
.ent finish
finish:
		b continue_finish
		mtc2 $k0, $0, 6

skip_cp2_setup:
		jalr $25
		nop
		#
		# Check to see if coprocessor 2 (capability unit) is present,
		# and dump out its registers if it is.
		#

		
continue_finish:		
		#
		# On multithreaded/multicore, only core/thread 0 halts 
		# the simulation.
		#
		# We do this check (which alters $k1) before we dump registers,
		# because we want the final register values to be the same
		# in both gxemul and BERI/CHERI.
		#
		# gxemul does not support the BERI-specific CoreId and
		# ThreadId registers, so we also check PrId.
		#

		mfc0 $k0, $15		# PrId
		andi $k0, $k0, 0xff00
		xori $k0, $k0, 0x8900
		beqz $k0, dump_core0
		nop

		mfc0 $k0, $15, 6	# CoreId
		andi $k0, $k0, 0xffff
		bnez $k0, dump_not_core0
		nop

		mfc0 $k0, $15, 7	# ThreadId
		andi $k0, $k0, 0xffff
		bnez $k0, dump_not_thread0
		nop

dump_core0:
		#
		# Load the exception count into k0 so that it is visible 
		# in register dump
		#
		dla			$k0, exception_count
		ld      $k0, 0($k0)

		#
		# Dump registers on the simulator (gxemul dumps regs on exit)
		#
		# We want the final register values to be the same in both
		# gxemul and BERI -- particularly for fuzz tests -- so
		# all modifications to registers should happen before this
		# point.
		#

		mtc0 $at, $26
		nop
		nop

		#
		# Terminate the simulator
		#

		mtc0 $at, $23
		nop
.global end
end:
		ori $0, $0, 0xdead	# stop tracing on QEMU
		b end
		daddiu $zero, $zero, 0  # load zero nop to indicate core 0


dump_not_thread0:
dump_not_core0:

		dla	$k0, exception_count
		ld	$k0, 0($k0)

		#
		# Dump registers even though core/thread not zero, so we
		# can see all cores in the trace.
		#

		mtc0 $at, $26
		nop
		nop

		#
		# On a multicore or multithreaded CPU, loop until core0
		# finishes its work and kills the simulation. Other cores
		# might reach this point before core0 finishes, and we want
		# core0 to get to the point where it dumps its registers to
		# the trace.
		#

end_not_core0:
		b end_not_core0
		daddiu $zero, $zero, 1 # load 1 nop to indicate core != 0

.end finish

		.ent die_on_exception
.global die_on_exception
die_on_exception:
		# TODO: only do this on a CP2 exception!
		daddiu $k0, 1		# notify test that we have an exception
		dli $v0, 0xbadc		# exit code for die on exception
		b finish
		nop
.end die_on_exception


# This stub handler is copied to 0xfffffffffff00000000180 and just jumps to the real handler
.global jump_to_real_trap_handler
.ent jump_to_real_trap_handler
jump_to_real_trap_handler:
		.set push
		.set noat
		.global default_trap_handler
		dla	$k0, default_trap_handler
		jalr	$k0
		nop
end_of_jump_to_real_trap_handler:
		nop
		.set pop
.end jump_to_real_trap_handler


		.global exception_count_handler
		.ent exception_count_handler
exception_count_handler:
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		sd      $k0,  8($sp)
		daddu	$fp, $sp, 32

.ifdef DIE_ON_EXCEPTION
		dla	$k0, continue_after_exception
		beqz	$k0, die_on_exception		# abort if variable is NULL
		nop

		ld	$ra, 0($k0)
		ble	$ra, $zero, die_on_exception	# also abort if die_on_exception is not greater 0
		nop

		dsubu	$ra, $ra, 1		# reduce number of skippable exceptions by one
		sd	$ra, 0($k0)
.endif


		# Increment exception counter
		dla     $ra, exception_count
		ld      $k0, ($ra)
		addi    $k0, $k0, 1
		sd      $k0, ($ra)

		# If this is a timer interrupt, then return to the current instruction
		dmfc0	$k0, $13
		andi	$k0, $k0, 0x8000
		beq	$zero, $k0, increment_pc 
		nop
		# Clear the timer interrupt
		mtc0	$zero, $11
		b skip_increment
		nop
increment_pc:
		# Skip the instruction which caused exception and return
		dmfc0	$k0, $14	# EPC
		daddiu	$k0, $k0, 4	# EPC += 4 to bump PC forward on ERET
		dmtc0	$k0, $14
skip_increment:

	        ld	$ra, 24($sp)
		ld	$fp, 16($sp)
	        ld      $k0,  8($sp)
		daddu	$sp, $sp, 32
		nop			# NOPs to avoid hazard with ERET
		nop			# XXXRW: How many are actually
		nop			# required here?
		nop
		eret
end_of_exception_count_handler:
		nop
		nop
.end exception_count_handler


# install_tlb_entry(tlb_entry, physical_base, virtual_base, page_mask)
.ent install_tlb_entry
.global install_tlb_entry
install_tlb_entry:
		dmtc0        $a3, $5                 # Write page mask i.e. 0 for 4k pages, 0x3FF for 4M pages
		dmtc0        $a0, $0                 # TLB index
		dmtc0        $a2, $10                # TLB HI address
		dli          $at, 0xfffffff000       # Get physical page (PFN) of the physical address (40 bits less 12 low order bits)
		and          $t1, $a1, $at
		dsrl         $t2, $t1, 6             # Put PFN in correct position for EntryLow
		ori          $t2, $t2, 0x13          # Set valid and global bits, uncached
		dmtc0        $t2, $2                 # TLB EntryLow0
		daddu        $t3, $t2, 0x40          # Add one to PFN for EntryLow1
		dmtc0        $t3, $3                 # TLB EntryLow1
		tlbwi                                # Write Indexed TLB Entry
		nop
		nop
		jr           $ra
	nop
.end install_tlb_entry

#
# By default threads other than thread 0 will enter a barrier on reset.
# This function causes thread 0 to enter the barrier, thereby releasing the
# other threads from their prison.
# Args: None
# Returns: Nothing
.global other_threads_go
.ent other_threads_go        
other_threads_go:
                dla          $a0, reset_barrier      # Load barrier data
                j            thread_barrier          # Tail call to the barrier
                nop                                  # (delay slot)
.end other_threads_go

	        .data
		.align 3
.globl exception_count
exception_count:
		.8byte	0x0
.size exception_count, 8
.globl continue_after_exception
continue_after_exception:
		.8byte	0x0
.size continue_after_exception, 8
reset_barrier:
                mkBarrier
