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
# Load from an address into reg a1, and then immediately move the value into
# a second register.  MIPS 4400 doesn't require (although does encourage)
# load delay slots.  By varying the number of NOPs, we can see how far a
# (possible) bug in pipeline might exist.
#

		.text
		.global start
start:
		# No NOP
		dla	$a0, dword0
		ld	$a1, 0($a0)
		move	$t0, $a1

		# One NOP
		dla	$a0, dword1
		ld	$a1, 0($a0)
		nop
		move	$t1, $a1

		# Two NOPs
		dla	$a0, dword2
		ld	$a1, 0($a0)
		nop
		nop
		move	$t2, $a1

		# Three NOPs
		dla	$a0, dword3
		ld	$a1, 0($a0)
		nop
		nop
		nop
		move	$t3, $a1

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end

		#
		# Pad out data so that each double word gets its own cache
		# line, ensuring maximum stall in the memory subsystem.
		#
		.data
		.align 5
dword0:		.dword	0xfedcba9876543210
		.align 5
dword1:		.dword	0xfedcba9876543210
		.align 5
dword2:		.dword	0xfedcba9876543210
		.align 5
dword3:		.dword	0xfedcba9876543210
