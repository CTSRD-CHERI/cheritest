#-
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

NUM_GREGS=32

class Variation(object):
    pass

class EnumVariation(Variation):
    def __init__(self, values):
        self.values=values

    def iterate_values(self):
        for v in self.values:
            yield v

class RegisterVariation(EnumVariation):
    def __init__(self):
        super(RegisterVariation, self).__init__(("$r%d"%n for n in range(NUM_GREGS)))

class RRROpcodeVariation(EnumVariation):
    opcodes = """
    ADD
    ADDU
    SUB
    SUBU
    SLT
    SLTU
    AND
    OR
    XOR
    NOR 
    """.split()
    def __init__(self):
        super(RRROpcodeVariation, self).__init__(RRROpcodeVariation.opcodes)

class CrossVariation(Variation):
    def iterate_values(self):
        variations=inspect.getmembers(self.__class__, lambda m: isinstance(m,Variation))
        for p in itertools.product(*(v[1].iterate_values() for v in variations)):
            yield dict((variations[i][0],p[i]) for i in xrange(len(variations)))

class MIPSInstruction(CrossVariation):
    pass

class RRRInstructions(MIPSInstruction):
    opcode=RRROpcodeVariation()
    rd=RegisterVariation()
    rs=RegisterVariation()
    rt=RegisterVariation()

    def iterate_asm(self):
        for v in self.iterate_values():
            yield "%(opcode)s %(rd)s, %(rs)s, %(rt)s"%v    

class TestGenerator(object):
    pass

class InstructionPairGenerator(TestGenerator):
    
    def generate_test(self, n):
        pass
