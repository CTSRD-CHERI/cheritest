#-
# Copyright (c) 2012 Robert M. Norton
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

# Simple TLB test which configures a TLB entry for the lowest virtual
# page in the xuseg segment and attempts a store via it.

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
	# Set up exception handler.
	#
	jal	bev_clear
	nop

        jal     get_thread_id
        bnez    $v0, thread1
        nop

thread0:        
	dla	$a0, bev0_handler
	jal	bev0_handler_install
	nop

        jal     other_threads_go
        nop
        
        dla     $a0, 0x9800000003f80400
        li      $t0, 0x8
        sd      $t0, 16($a0)  # unmask int 3
        sd      $t0, 152($a0) # map int 3 to thread 1, int 0
        sd      $t0, 0($a0)   # set int 3

the_end:
        dla    $a0, my_barrier
        jal    thread_barrier
        nop
       
	ld	$fp, 16($sp)
	ld	$ra, 24($sp)
	jr      $ra
	daddu	$sp, $sp, 32
.end    test
	
thread1:
        dmfc0  $t0, $12       # get status register
        or     $t0, 0x401     # unmask interrupt 0 and enable interrupts
        and    $t0, ~0x6      # clear ERL, EXL
        dmtc0  $t0, $12       # set status register

        b      .              # wait to be interrupted
        mfc0   $a2, $13       # read cause

after_interrupt:
        j      the_end
        nop

#
# Exception handler
#
	.ent bev0_handler
bev0_handler:	
	dmfc0	$a0, $13	# Cause register
	dmfc0	$a1, $14	# EPC
	        
        b       after_interrupt
        nop
	.end bev0_handler

.data
my_barrier:
        mkBarrier
