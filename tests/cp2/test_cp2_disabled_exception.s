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
# Test to check that a cp2 instruction causes an exception if cp2 is
# not enabled.
#
# Outputs to check:
#
# $a0 - exception counter (should be 1)
# $a1 - cause register from last trap (should be TRAP)
# $a2 - EPC register from last trap (should be 0x10)
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Set up 'handler' as the RAM exception handler.
		#
		jal	bev_clear
		nop
		dla	$a0, exception_handler
		jal	bev0_handler_install
		nop

		#
		# Initialise trap counter.
		#
		dli	$a0, 0

	        # Disable CP2 in status register 
	        mfc0    $at, $12
                li	$t1, 1 << 30
                nor     $t1, $0          # invert to form mask
                and     $at, $at, $t1
	        mtc0    $at, $12
	        nop
	        nop
	        nop
	        nop
	        nop

expected_epc:
                # Attempt to clear tag on cp0. This should cause exception
                # as cp2 is disabled.
                ccleartag $c0

return:
                # Re-enable CP2 in status register 
	        mfc0    $at, $12
                li	$t1, 1 << 30
                or      $at, $at, $t1
	        mtc0    $at, $12

                # Save expected epc for later comparison
                # with a2
                dla     $a3, expected_epc
        
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test


#
# Exception handler. This code assumes that the trap was not in a branch delay slot.
#
		.ent exception_handler
exception_handler:
		daddiu	$a0, $a0, 1	# Increment trap counter        
		dmfc0	$a1, $13	# Get cause register
		dmfc0	$a2, $14        # get EPC

		# Set EPC to continue after exception return
		dla	$k0, return
		dmtc0	$k0, $14
		eret
		.end exception_handler
