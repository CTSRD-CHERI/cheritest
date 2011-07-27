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
# Generic init.s used by low-level CHERI regression tests.  Set up a stack
# using memory set aside by the linker, and allocate an initial 32-byte stack
# frame (the minimum in the MIPS ABI).  Install some default exception
# handlers so we can try and provide a register dump even if things go
# horribly wrong during the test.
#

start:
		# Set up stack and stack frame
		dla	$fp, __sp
		dla	$sp, __sp
		daddu 	$sp, $sp, -32

		# Install default exception handlers
		dla	$a0, exception_end
		jal 	bev0_handler_install
		nop

		dla	$a0, exception_end
		jal	bev1_handler_install
		nop

		#
		# Explicitly clear most registers in order to make the effects
		# of a test on the register file more clear.  Otherwise,
		# values leaked from init.s and its dependencies may hang
		# around.
		#
		dli	$at, 0
		dli	$v0, 0
		dli	$v1, 0
		dli	$a0, 0
		dli	$a1, 0
		dli	$a2, 0
		dli	$a3, 0
		dli	$a4, 0
		dli	$a5, 0
		dli	$a6, 0
		dli	$a7, 0
		dli	$t0, 0
		dli	$t1, 0
		dli	$t2, 0
		dli	$t3, 0
		dli	$s0, 0
		dli	$s1, 0
		dli	$s2, 0
		dli	$s3, 0
		dli	$s4, 0
		dli	$s5, 0
		dli	$s6, 0
		dli	$s7, 0
		dli	$t8, 0
		dli	$t9, 0
		dli	$k0, 0
		dli	$k1, 0
		dli	$gp, 0
		# Not cleared: $sp, $fp, $ra
		mthi	$at
		mtlo	$at

		# Invoke test function test() provided by individual tests.
		jal test
		nop			# branch-delay slot

		# Dump registers on the simulator
exception_end:
		mtc0 $at, $26
		nop
		nop

		# Terminate the simulator
	    mtc0 $at, $23
end:
		b end
		nop
