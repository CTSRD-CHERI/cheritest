#-
# Copyright (c) 2013-2014 Michael Roe
# Copyright (c) 2018 Alex Richardson
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

.include "macros.s"

#
# Test that cunseal checks for permitSeal permission
#

sandbox:
		creturn

BEGIN_TEST
		#
		# Make $c1 a data capability for 'data'
		#

		cgetdefault $c1
		dla	$t0, data
		csetoffset $c1, $c1, $t0
		dli	$t0, 0x4000
		csetbounds $c1, $c1, $t0
		dli	$t0, 0xd  # Permit_Store, Permit_Load and Global
		candperm $c1, $c1, $t0

		#
		# Make $c2 a template capability for type 0x1234
		#

		dli	$t0, 0x1234
		cgetdefault $c2
		csetoffset $c2, $c2, $t0

		cseal	$c3, $c1, $c2

		#
		# Remove Permit_Unseal permission from $c2
		#

		dli	$t0, ~__CHERI_CAP_PERMISSION_PERMIT_UNSEAL__
		candperm $c2, $c2, $t0

		#
		# Clear $c4 so we can later tell if its been modified
		#

		cgetdefault	$c4

		clear_counting_exception_handler_regs
		cunseal $c4, $c3, $c2 # This should raise an exception
		save_counting_exception_handler_cause $c5	# store trap info in $c5

		# The exception handler should return to here, and
		# $c4 should have been unchanged by the failed attempt to
		# unseal, so $c4.base should be 0.
		cgetbase $a0, $c4

END_TEST

		.data
		.align	12
data:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef

