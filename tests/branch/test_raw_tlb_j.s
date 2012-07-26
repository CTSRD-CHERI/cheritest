#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2012 Robert M. Norton
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
# Test for a sequence of instructions on Cheri2 that triggered a bug.
# Problem occurs when a branch is already past execute when an exception
# occurs which lands on a jump.
#

		.global start
start:
                nop 
                nop
        
                # Clear BEV bit
                mfc0	$t0, $12
		dli	$t1, 1 << 22	# BEV bit
		nor	$t1, $t1
		and	$t0, $t0, $t1
		mtc0	$t0, $12

                # Copy some code to the exception vector
                dla     $t0, tlb_miss_vector
                ld      $t1, 0($t0)
                # the test is very timing/alignment sensitive such that uncommenting
                # the extra load/store means the test no longer triggers the bug.
                # Therefore we have to tolerate that the test will fail by going awol.
                #ld      $t2, 8($t0)
                dla     $t0, 0xffffffff80000080
                sd      $t1, 0($t0)
                #sd      $t2, 8($t0)

                # Clear some flag registers
                li      $a0, 0
                li      $a1, 0
                li      $a2, 0
                li      $a3, 0
                li      $a4, 0
                li      $a5, 0
                li      $a6, 0
                li      $a7, 0

                dla     $k0, jump_target2               # Load target in k0
        
		li	$a0, 1
                sw      $zero, 0($zero)                 # Trigger TLB miss
		j	jump_target1                    # Shouldn't run
		li	$a1, 2				# Delay slot -- shouldn't run
		li	$a2, 3				# Shouldn't run
jump_target1:
		li	$a3, 4				# Shouldn't run
jump_target2:
		li	$a4, 5				# Should run

		# Dump registers in the simulator
		mtc0	$v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0	$v0, $23
end:
		b end
		nop
.align 3
tlb_miss_vector:
                jr     $k0 
                li     $a5, 6
                jr     $k0    # backup, in-case the first just fails...
                li     $a6, 7
