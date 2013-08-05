#-
# Copyright (c) 2013 Robert M. Norton
# All rights reserved.
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

# Test memory access to regions of address space with no valid mapping, such
# as physical addresses larger than the physical address space (PABITS) and
# virtual addresses higher than the virtual segment size (SEGBITS).        

# Register assignment:
# a0 - desired epc 1
# a1 - actual epc 1
# a2 - desired badvaddr 1
# a3 - actual badvaddr 1
# a4 - cause 1
# a5 - desired epc 2
# a6 - actual  epc 2
# a7 - desired badvaddr 2
# s0 - actual  badvaddr 2
# s1 - cause 2
	
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
		# Set up 'handler' as the RAM exception handler.
		#
		jal	bev_clear
		nop

		dla	$a0, bev0_handler
		jal	set_bev0_common_handler
		nop

		dla	$a0, bev0_handler
		jal	set_bev0_xtlb_handler
		nop


		dli	$s0, 0
		dli	$s1, 0
		dli	$s2, 0

                dla     $a0, desired_epc1
                dla     $a2, 0x0001000000100000
desired_epc1:	ld      $a5, 0($a2)		# Load from bad user space virtual address (virtual address too large)
                move    $a1, $s0                # stash EPC
                move    $a3, $s1                # stash bad addr
                move    $a4, $s2                # stash cause

		dli	$s0, 0
		dli	$s1, 0
		dli	$s2, 0

                dla     $a5, desired_epc2
                dla     $a7, 0x9801000000100000
desired_epc2:	ld      $a7, 0($a7)		# Load from bad kernel space address (too large for physical address space)
                move    $a6, $s0                # stash EPC  
                move    $s0, $s1                # stash bad addr
                move    $s1, $s2                # stash cause

return:
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

#
# Exception handler.  
#
		.ent bev0_handler
bev0_handler:
		dmfc0   $s0, $14      		# EPC
		daddu   $t0, $s0, 4		# Increment EPC
		dmtc0   $t0, $14		# and store it back
		dmfc0	$s1, $8			# BadVAddr
		dmfc0	$s2, $13		# Cause
		eret
		.end bev0_handler

