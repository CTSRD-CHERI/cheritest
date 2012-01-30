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
import random

def make_list(s):
    return [l for l in s.split() if len(l)>0 and l[0]!='#']

def generate_tests(options, group, variables):
    test_no=0
    fuzz_dir=os.path.dirname(inspect.getfile(inspect.currentframe()))
    template=string.Template(open(os.path.join(fuzz_dir,group+"_template.txt")).read())
    for params in itertools.product(*[var[1] for var in variables]):
        test_name="test_fuzz_%s_%08d" % (group, test_no)
        test_path_base=os.path.join(options.test_dir,test_name)
        test_asm_path=test_path_base+".s"
        param_dict=dict(zip([var[0] for var in variables],params))
        param_dict["nops"]="\tnop\n" * param_dict["nops"]
        random.seed(test_no)
        param_dict["a0_val"]="0x%016x"% random.randint(0,0xffffffffffffffff)
        param_dict["a1_val"]="0x%016x"% random.randint(0,0xffffffffffffffff)
        test_asm=open(test_asm_path, 'w')
        test_asm.write(template.substitute(param_dict))
        test_asm.close()
        test_no+=1
    print "generated %d %s tests" % (test_no, group)

def generate_load(options):
    ops=make_list("""
    LB
    LBU
    LD
    LDL
    LDR
    LH
    LHU
    LW
    LWU
    LWL
    LWR
    #LL
    #LLD
    """)
    generate_tests(options, 'load', [
            ('op',ops),
            ('offset', range(7)),
            ('rs',['$0','$a0']),
            ('rt',['$0','$a0']),
            ('nops', range(7)),
            ])
    

def generate_arithmetic(options):
    ops= make_list("""
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
    DADD
    DADDU
    DSUB
    DSUBU
    DSLL
    DSRA
    DSRL
    """)
    #TODO $ra is also special...
    # rd0 is either zero reg or a gp reg
    rd0_regs=make_list("""
    $a0
    """)
    # rd1 is gp reg (maybe same as rd0)
    rd1_regs=make_list("""
    $a1
    """)
    # source regs are either zero, same as rd0, or something else
    source0_regs=make_list("""
    $0
    $a0
    $a1
    """)
    source1_regs=make_list("""
    $0
    $a1
    $a0
    """)
    nops=[0]

    generate_tests(
        options, 
        "alu", 
        [ ('op0', ops),
          ('rd0', rd0_regs),
          ('rs0', source0_regs),
          ('rt0', source0_regs),
          ('op1', ops),
          ('rd1', rd1_regs),
          ('rs1', source1_regs),
          ('rt1', source1_regs),
          ('nops', nops),])

if __name__=="__main__":
    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option("-d", "--test-dir",
                      help="Directory to generate tests in.", default="tests/fuzz")
    (options, args) = parser.parse_args()
    generate_arithmetic(options)
    generate_load(options)



