#-
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
# Generic init.s used by low-level CHERI fuzz tests. Identical to
# init.s except that registers are initialised to more interesting
# values and cp2 regs are not dumped because gxemul does not have cp2 yet...
#
		.text
		.global start
		.ent start
#
# When we want to run the CHERI unit test suite at a cached address, the
# tests are linked with that base in mind.  This small stub jumps to the
# cached start address.  We clear $t0 so that later test code sees the
# presumed zero value from processor initialisation expected by, for example,
# test_raw_reginit.  This is not ideal, but there's no way to jump to the
# right address without using a register at all.
#
uncached_start:
		dla	$t0, start
		jr	$t0
		move	$t0, $zero	# branch-delay slot
start:
		# Set up stack and stack frame
		dla	$fp, __sp
		dla	$sp, __sp
		daddu 	$sp, $sp, -32

		# Install default exception handlers
		dla	$a0, bev0_handler
		jal 	bev0_handler_install
		nop

		dla	$a0, bev0_handler
		jal	bev1_handler_install
		nop

	        # Switch to 64-bit mode (no effect on cheri, but required for gxemul)
	        mfc0    $at, $12
	        or      $at, $at, 0xe0
	        mtc0    $at, $12
	
		#
		# Initialise registers to some fixed values to use as
	        # a 'fixture'.
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
		jal test
		nop			# branch-delay slot

exception_end:
		ld      $k0, exception_count
		
		# Dump registers on the simulator
		mtc0 $at, $26
		nop
		nop

		# Dump capability registers in the simulator -- not supported on gxemul
		#mfc2 $v0, $0, 4
		#nop
		#nop

		# Terminate the simulator
		mtc0 $at, $23
end:
		b end
		nop
		.end start

exception_handler:
		.ent bev0_handler
bev0_handler:
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
	        sd      $k0,  8($sp)
		daddu	$fp, $sp, 32
	

		# Increment exception counter
	        dla     $ra, exception_count
		ld      $k0, ($ra)
	        addi    $k0, $k0, 1
	        sd      $k0, ($ra)

		# Skip the instruction which caused exception and return
		dmfc0	$k0, $14	# EPC
		daddiu	$k0, $k0, 4	# EPC += 4 to bump PC forward on ERET
		dmtc0	$k0, $14

	        ld	$ra, 24($sp)
		ld	$fp, 16($sp)
	        ld      $k0,  8($sp)
		daddu	$sp, $sp, 32
		nop			# NOPs to avoid hazard with ERET
		nop			# XXXRW: How many are actually
		nop			# required here?
		nop
		eret
		.end bev0_handler

	.data
	.align 3
exception_count:
		.dword	0x0