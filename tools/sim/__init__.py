#-
# Copyright (c) 2011 Steven J. Murdoch
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

import re

## Mapping of register numbers and register names, used internally and by the
## predicate itself in generating error messages, etc.
MIPS_REG_NUM2NAME=[
  "zero", "at", "v0", "v1", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7",
  "t0", "t1", "t2", "t3", "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "t8",
  "t9", "k0", "k1", "gp", "sp", "fp", "ra"
]

## Inverse mapping of register name to register number
MIPS_REG_NAME2NUM={}
for num, name in enumerate(MIPS_REG_NUM2NAME):
    MIPS_REG_NAME2NUM[name] = num

## Regular expressions for parsing the log file
MIPS_REG_RE=re.compile(r'^DEBUG MIPS REG\s+([0-9]+) (0x................)$')
MIPS_PC_RE=re.compile(r'^DEBUG MIPS PC (0x................)$')
CAPMIPS_PC_RE = re.compile(r'^DEBUG CAP PCC u:(.) perms:(0x.{4}) ' +
                           r'type:(0x.{16}) base:(0x.{16}) length:(0x.{16})$')
CAPMIPS_REG_RE = re.compile(r'^DEBUG CAP REG\s+([0-9]+) u:(.) perms:(0x.{4}) ' +
                            r'type:(0x.{16}) base:(0x.{16}) length:(0x.{16})$')

class MipsException(Exception):
    pass

class MipsStatus(object):
    '''Represents the status of the MIPS CPU registers, populated by parsing
    a log file. If x is a MipsStatus object, registers can be accessed by name
    as x.<REGISTER_NAME> or number as x[<REGISTER_NUMBER>].'''
    def __init__(self, fh):
        self.fh = fh
        self.start_pos = self.fh.tell()
        self.reg_vals = [None] * len(MIPS_REG_NUM2NAME)
        self.pc = None
        self.parse_log()
        if self.pc is None:
            raise MipsException("Failed to parse PC from %s"%self.fh)
        for i in range(len(MIPS_REG_NUM2NAME)):
            if self.reg_vals[i] is None:
                raise MipsException("Failed to parse register %d from" +
                                    "%s"%(i,self.fh))

    def parse_log(self):
        '''Parse a log file and populate self.reg_vals and self.pc'''
        for line in self.fh:
            line = line.strip()
            reg_groups = MIPS_REG_RE.search(line)
            pc_groups = MIPS_PC_RE.search(line)
            if (reg_groups):
                reg_num = int(reg_groups.group(1))
                reg_val = int(reg_groups.group(2), 16)
                self.reg_vals[reg_num] = reg_val
            if (pc_groups):
                reg_val = int(pc_groups.group(1), 16)
                self.pc = reg_val

    def reset_fh(self):
        self.fh.seek(self.start_pos)

    def __getattr__(self, key):
        '''Return a register value by name'''
        reg_num = MIPS_REG_NAME2NUM.get(key, None)
        if reg_num is None:
            raise MipsException("Not a valid register name", key)
        return self.reg_vals[reg_num]

    def __getitem__(self, key):
        '''Return a register value by number'''
        if not type(key) is int or key < 0 or key > len(MIPS_REG_NUM2NAME):
            raise MipsException("Not a valid register number", key)
        return self.reg_vals[key]

    def __repr__(self):
        v = []
        for i in range(len(self.reg_vals)):
            v.append("%3d: 0x%016x"%(i, self.reg_vals[i]))
        v.append(" PC: 0x%016x"%(self.pc))
        return "\n".join(v)

class Capability(object):
    def __init__(self, u, perms, ctype, base, length):
        self.u = int(u)
        self.perms = int(perms, 16)
        self.ctype = int(ctype, 16)
        self.base = int(base, 16)
        self.length = int(length, 16)

    def __repr__(self):
        return 'u:%x perms:0x%04x type:0x%016x base:0x%016x length:0x%016x'%(
            self.u, self.perms, self.ctype, self.base, self.length)

class CapMipsStatus(MipsStatus):
    '''Represents the status of the capability enhanced MIPS CPU registers'''
    def __init__(self, fh):
        ## Read the normal MIPS registers
        MipsStatus.__init__(self, fh)
        self.cp2 = [None] * 32
        self.pcc = None
        ## Reset file handle for reading capability registers
        self.reset_fh()
        for line in self.fh:
            line = line.strip()
            reg_groups = CAPMIPS_REG_RE.search(line)
            pc_groups = CAPMIPS_PC_RE.search(line)
            if (reg_groups):
                reg_num = int(reg_groups.group(1))
                self.cp2[reg_num] = Capability(*reg_groups.groups()[1:6])
            if (pc_groups):
                self.pcc = Capability(*pc_groups.groups()[0:5])

    def __getattr__(self, key):
        '''return a register value by name'''
        regnum = None
        if key.startswith("c"):
            try:
                regnum = int(key[1:])
            except ValueError, e:
                pass
        if regnum != None:
            return self.cp2[regnum]
        else:
            return MipsStatus.__getattr__(self, key)

    def __repr__(self):
        v = []
        for i in range(len(self.cp2)):
            reg_num = ("c%d"%i).rjust(3)
            v.append("%s: %s"%(reg_num, self.cp2[i]))
        v.append("PCC: %s"%(self.pcc))
        return MipsStatus.__repr__(self) + "\n" + "\n".join(v)

