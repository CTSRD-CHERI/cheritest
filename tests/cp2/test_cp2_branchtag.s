#-
# Copyright (c) 2012 Michael Roe
# Copyright (c) 2013 David Chisnall
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
# Basic test of the CBTS and CBTU instructions.  
#


.global test
test:
.ent test
	dli       $a0, 0
	dli       $a1, 0

	# c0 should have a valid cap, c1 an invalid one
	CClearTag $c1

	# Check that the branches are taken when they should be and that their
	# delay slots execute.
	CBTS      $c0, clear1
	daddi     $a0, $a0, 1
cont1:
	CBTU      $c1, clear2
	daddi     $a1, $a1, 1
cont2:
	# Check that the branches are not taken when they shouldn't be and that
	# their delay slots execute.
	CBTS      $c1, clear3
	daddi     $a0, $a0, 2
cont3:
	CBTU      $c0, clear4
	daddi     $a1, $a1, 2
cont4:

	# By this point, a0 and a1 should both be 0b111 (7).  Each of the delay
	# slots will set one of the low bits and each of the branch targets will
	# set one of the next bits, but only one of the targets should be reached.

	jr        $ra
	nop  # branch-delay slot
clear1:
	b         cont1
	daddi     $a0, $a0, 4 # in delay slot
clear2:
	b         cont2
	daddi     $a1, $a1, 4 # in delay slot
# Should not be reached:
clear3:
	b         cont3
	daddi     $a0, $a0, 8 # in delay slot
clear4:
	b         cont4
	daddi     $a1, $a1, 8 # in delay slot
.end	test
