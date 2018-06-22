#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2013 Alan A. Mujumdar
# Copyright (c) 2014 Michael Roe
# Copyright (c) 2018 Jonathan Woodruff
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-11-C-0249
# ("MRC2"), as part of the DARPA MRC research programme.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory (Department of Computer Science and
# Technology) under DARPA contract HR0011-18-C-0016 ("ECATS"), as part of the
# DARPA SSITH research programme.
#
# @BERI_LICENSE_HEADER_START@
#
# Licensed to BERI Open Systems C.I.C. (BERI) under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  BERI licenses this
# file to you under the BERI Hardware-Software License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at:
#
#   http://www.beri-open-systems.org/legal/license-1-0.txt
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @BERI_LICENSE_HEADER_END@
#

.include "macros.s"

.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test virtual device on a dual core system
#
# Service a read request from core 0 on core 1.
#
BEGIN_TEST
		jal	other_threads_go
		nop
		dmfc0	$t0, $15, 7		# Thread Id ...
		andi	$t0, $t0, 0xffff	# ... in bottom 16 bits
		bnez	$t0, end		# If we're not thread zero
		nop				# Branch delay slot
		
		dmfc0	$t0, $15, 6		# Core Id ...
		andi	$t0, $t0, 0xffff	# ... in bottom 16 bits
		dli	$t1, 1
		beq	$t0, $t1, core1		# If we're core onr
		nop				# Branch delay slot
		bnez	$t0, end		# If we're not core zero
		nop				# Branch delay slot

		#
		# Core 0 does this bit
		#
		dli	$t0, 0x900000007fb00000	# Load address of virt. device
		ld	$a0, 0($t0)		# Should return as not enabled
		dli	$t1, 0x900000007ff00000	# Load address of reg interface
		li	$t2, 1
		sb	$t2, 0x2008($t1)
		ld	$a1, 0($t0)		# Should be served by core1

		b end
		nop

		#
		# Only core1 does this bit
		#

core1:
	        dli	$t0, 0x900000007ff00000	# Load address of reg interface
read_loop:
	        lb	$t1, 0x2007($t0)	# Poll waiting for request
	        beqz	$t1, read_loop
	        nop
	        
	        ld	$t1, 0x1000($t0)	# Load the address
	        sd	$t1, 0x0040($t0)	# Store address to response data
	        sd	$0,  0x2000($t0)	# Trigger response

end:

END_TEST

