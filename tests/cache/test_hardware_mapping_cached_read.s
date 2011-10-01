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
# Exercise cached and uncached hardware direct maps:
#
# (1) Cached read from data address
# (2) Uncached write to data address
# (3) Cached read from data address
#
# Assuming that the cache is implemented (possibly not true for ISA
# simulators but generally true of hardware), (3) should not see the results
# of (2), regardless of write back/write through configuration.  We attempt
# to check the CP0 config register 'DC' and 'SC' fields to determine if a
# cache should be present, which will help the test case determine if this
# test should fail (or not).
#
# xkphys addresses are used.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Retrieve CP0 config register so that test cases can
		# determine expected behaviour for our instruction sequence.
		#
		mfc0	$s1, $16

		#
		# Read via uncached address (address saved in $s0).
		#
		dla	$s0, dword
		ld	$a0, 0($s0)

		#
		# Calculate cached address (address saved in $gp).
		#
		dla	$gp, dword
		dli	$t0, 0x00ffffffffffffff
		and	$gp, $gp, $t0
		dli	$t0, 0x9800000000000000
		daddu	$gp, $gp, $t0

		#
		# (1) Read via cached address; brings line into data cache.
		#
		ld	$a1, 0($gp)

		#
		# (2) Write via uncached address; should not affect data cache
		# line.
		#
		dli	$t1, 0xafafafafafafafaf
		sd	$t1, 0($s0)

		#
		# (3) Read via cached address; should see previously written
		# value.
		#
		ld	$a2, 0($gp)

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

# A double word of data that we will load and store via various
# hardware-defined mappings.
dword:		.dword	0x0123456789abcdef
