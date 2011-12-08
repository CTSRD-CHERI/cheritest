#-
# Copyright (c) 2011 Robert M. Norton
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

# Script to generate fuzz tests. This just generates .s files in
# tests/fuzz. The make file arranges to build and run them with
# bluesim and gxemul. tests/fuzz/test_fuzz.py is a nose test which
# compares the results.

import itertools
import inspect
import string
import os

if __name__=="__main__":
    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option("-d", "--test-dir",
                      help="Directory to generate tests in.", default="tests/fuzz")
    (options, args) = parser.parse_args()
    
    fuzz_dir=os.path.dirname(inspect.getfile(inspect.currentframe()))

    ops= """
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
    SLL
    SRA
    SRL
    """.split()
    #TODO $ra is also special...
    # rd0 is either zero reg or a gp reg
    rd0_regs="""
    $0
    $a0
    """.split()
    # rd1 is gp reg (maybe same as rd0)
    rd1_regs="""
    $a0
    $a1
    """.split()
    # source regs are either zero, same as rd0, or something else
    source0_regs="""
    $0
    $a0
    $a1
    """.split()
    source1_regs="""
    $0
    $a0
    $a1
    """.split()
    nops=range(7)
    test_no=0
    template=string.Template(open(os.path.join(fuzz_dir,"asm_template.txt")).read())
    for params in itertools.product(
            ops, \
            rd0_regs, \
            source0_regs, \
            source0_regs, \
            ops, \
            rd1_regs, \
            source1_regs, \
            source1_regs, \
            nops):
        test_name="test_fuzz_%08d" % (test_no)
        test_path_base=os.path.join(options.test_dir,test_name)
        test_asm_path=test_path_base+".s"
        test_asm=open(test_asm_path, 'w')
        param_dict=dict(zip(["op0","rd0","rs0","rt0","op1","rd1","rs1","rt1","nops"],params))
        param_dict["nops"]="\tnop\n" * param_dict["nops"]
        test_asm.write(template.substitute(param_dict))
        test_asm.close()
        test_no+=1
    print "generated %d tests" % (test_no+1)
