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
# Test that a store followed immediately by a load gets the correct value.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Clear registers we'll use when testing results later.
		#
		dli	$a0, 0
		dli	$a1, 0
		dli	$a2, 0
		dli	$a3, 0
		dli	$a4, 0
		dli	$a5, 0
		dli	$a6, 0
		dli	$a7, 0


                dla     $a0, bytes
                dli     $a1, 0x5656565656565656
                li      $t0, 0

                # exeucte the test in a loop to pre-cache the instructions
loop:
                nop
                nop
                ld      $a2, 0($a0)
                ld      $a3, 0($a0)
                ld      $a4, 0($a0)
                sd      $a1, 0($a0)
                ld      $a5, 0($a0)
                ld      $a6, 0($a0)
                ld      $a7, 0($a0)
                nop
                nop
                sd      $a1, 0($a0)
                # change the stored value second time round to actually do the test
                dli     $a1, 0xfeedbeefdeadbeef
                beqz    $t0, loop
                add     $t0, 1
        
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

		.data
		.align	5
bytes:		.dword	0x5656565656565656
