#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2013 Robert M. Norton
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
# Test for reads from aliased memory regions. It works on cheri2 because
# addresses at the same page offset will alias in the caches, but this
# might not work for cheri.
#

		.global test
		.ent test
test:
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

                dla     $a0, page0
                dla     $a1, page1
                dla     $a2, page2

                #
		# Load repeatedly from three aliasing addresses.
                # Do this twice to warm up the icache and sprinkle
		# a couple of stores in just for kicks.
                #

                li      $t0, 1
loop:
                nop
                nop
                nop
                ld      $a3, 0($a0)
                ld      $a4, 0($a1)
                ld      $a5, 0($a0)
                ld      $a6, 0($a1)
                ld      $a7, 0($a2)
                ld      $s0, 0($a0)
                ld      $s1, 0($a1)
                ld      $s2, 0($a1)
                ld      $s3, 0($a2)
                ld      $s4, 0($a2)
                sd      $0,  0($a2)
                ld      $s5, 0($a2)
                sd      $0,  0($a1)
                ld      $s6, 0($a1)
                ld      $s7, 0($a0)
                # reset memory to its original state
                dli     $t1, 0x1011121314151617
                sd      $t1, 0($a1)
                dli     $t1, 0x2021222324252627
                sd      $t1, 0($a2)
                bgtz    $t0, loop
                sub     $t0, 1
        
return:
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

.data
page0:  
        .rept 512
        .dword 0x0001020304050607
        .endr
page1:  
        .rept 512
        .dword 0x1011121314151617
        .endr
page2:
        .rept 512
        .dword 0x2021222324252627
        .endr
