#-
# Copyright (c) 2011 Steven J. Murdoch
# Copyright (c) 2013-2016 Alexandre Joannou
# Copyright (c) 2014 Jonathan Woodruff
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
# ("CTSRD"), as part of the DARPA CRASH research programme.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-11-C-0249
# ("MRC2"), as part of the DARPA MRC research programme.
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

import os
import re
from collections import defaultdict
from enum import Enum

try:
    import typing
except ImportError:
    typing = object()

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
# does a line.startswith() before full regex matching to speed up logfile parsing
class FasterRegex(object):
    def __init__(self, line_start, remaining):
        self.line_start = line_start
        assert self.line_start
        self.regex = re.compile('^' + line_start + remaining)

    def search(self, line):
        if not line.startswith(self.line_start):
            return None
        return self.regex.search(line)



hdigit="[0-9A-Fa-f]"
# FIXME: is this also at start of line? If so we can speed it up by using the FastRegex class
THREAD_RE=re.compile(r'======\s+Thread\s+([0-9]+)\s+======$')
MIPS_CORE_RE=FasterRegex('DEBUG MIPS COREID', r'\s+([0-9]+)$')
MIPS_REG_RE=FasterRegex('DEBUG MIPS REG', r'\s+([0-9]+)\s+(0x................)$')
MIPS_PC_RE=FasterRegex('DEBUG MIPS PC', r'\s+(0x................)$')
CAPMIPS_CORE_RE=FasterRegex('DEBUG CAP COREID', r'\s+([0-9]+)$')

CAPREG_DUMP_REGEX = r't:([01])\s+[su]:([01]) perms:(0x' + hdigit + '+) type:(0x' + \
                     hdigit + '+) offset:(0x' + hdigit + '{16}) base:(0x' + \
                     hdigit + '{16}) length:(0x' + hdigit + '{16})'
CAPMIPS_PC_RE = FasterRegex('DEBUG CAP PCC', r'\s+' + CAPREG_DUMP_REGEX + '$')
CAPMIPS_REG_RE = FasterRegex('DEBUG CAP REG', r'\s+([0-9]+)\s+' + CAPREG_DUMP_REGEX + '$')
CAPMIPS_HWREG_RE = FasterRegex('DEBUG CAP HWREG', r'\s+(\d+)\s+(\(\w+\))?\s*' + CAPREG_DUMP_REGEX + '$')


class MipsException(Exception):
    pass


def is_envvar_true(var):
    '''Return true iff the environment variable specified is defined and
    not set to "0"'''
    return os.environ.get(var, "0") != "0"


# Ensures that assertion messages print this as hex (e.g. capability length, etc)
class HexInt(int):
    def __repr__(self):
        return hex(self)


class Capability(object):
    def __init__(self, t, s, perms, ctype, offset, base, length):
        self.t      = t
        self.s      = s
        self.ctype  = HexInt(ctype)
        self.perms  = HexInt(perms)
        self.offset = HexInt(offset)
        self.base   = HexInt(base)
        self.length = HexInt(length)

    @property
    def address(self):
        # Since python ints are variable length we need a mod 2^64 to get a u64
        return HexInt((self.offset + self.base) & 0xffffffffffffffff)

    def __repr__(self):
        return '<t:%x s:%x perms:0x%08x type:0x%06x offset:0x%016x base:0x%016x length:0x%016x>'%(
            self.t, self.s, self.perms, self.ctype, self.offset, self.base, self.length)

    def __eq__(self, other):
        return self.t == other.t and self.s == other.s and \
            self.ctype == other.ctype and self.perms == other.perms and \
            self.offset == other.offset and self.base == other.base and \
            self.length == other.length

def capabilityFromStrings(t, s, perms, ctype, offset, base, length):
    return Capability(
        int(t),
        int(s),
        int(perms, 16),
        int(ctype, 16),
        int(offset, 16),
        int(base, 16),
        int(length, 16),
    )

class ThreadStatus(object):
    '''Data object representing status of a thread (including cp2 registers if present)'''
    def __init__(self):
        self.reg_vals = [None] * len(MIPS_REG_NUM2NAME)  # type: typing.List[int]
        self.pc = None  # type: int
        self.cp2 = [None] * 32  # type: typing.List[Capability]
        self.cp2_hwregs = [None] * 32  # type: typing.List[Capability]
        self.pcc = None  # type: Capability

    def __getattr__(self, key):
        '''Return a register value by name'''
        if key.startswith("chwr"):
            regnum = int(key[4:])
            val = self.cp2_hwregs[regnum]
            if val is None:
                raise MipsException("Attempted to read register not present or undef in log file: ", key)
            return val
        elif key.startswith("c"):
            regnum = int(key[1:])
            val = self.cp2[regnum]
            if val is None:
                raise MipsException("Attempted to read register not present or undef in log file: ", key)
            return val
        else:
            reg_num = MIPS_REG_NAME2NUM.get(key, None)
            if reg_num is None:
                raise MipsException("Not a valid register name", key)
            val = self.reg_vals[reg_num]
            if val is None:
                raise MipsException("Attempted to read register not present or undef in log file: ", key)
            return val

    def __getitem__(self, key):
        '''Return a register value by number'''
        if not type(key) is int or key < 0 or key > len(MIPS_REG_NUM2NAME):
            raise MipsException("Not a valid register number", key)
        val = self.reg_vals[key]
        if val is None:
            raise MipsException("Attempted to read register not present or undef in log file: ", key)
        return val

    @property
    def ddc(self):
        # type: (self) -> Capability
        return self._special_capreg(0, "$ddc")

    @property
    def kcc(self):
        # type: (self) -> Capability
        return self._special_capreg(29, "$kcc")

    @property
    def kdc(self):
        # type: (self) -> Capability
        return self._special_capreg(30, "$kdc")

    @property
    def epcc(self):
        # type: (self) -> Capability
        return self._special_capreg(31, "$epcc")

    @property
    def error_epcc(self):
        # type: (self) -> Capability
        return self._special_capreg(28, "$error_epcc")

    @property
    def idc(self):
        return self.cp2[26]

    # Return a capabilty
    def _special_capreg(self, number, name):
        # type: (self, int, str) -> Capability
        assert self.cp2_hwregs[number] is not None, "CapHWR {} ({}) not defined?".format(number, name)
        return self.cp2_hwregs[number]

    # noinspection PyStringFormat
    def __repr__(self):
        v = []
        for i in range(len(self.reg_vals)):
            v.append("%3d: 0x%016x"%(i, self.reg_vals[i]))
        v.append(" PC: 0x%016x"%(self.pc))
        v.append('')
        for i in range(len(self.cp2)):
            reg_num = ("c%d"%i).rjust(3)
            v.append("%s: %s"%(reg_num, self.cp2[i]))
        v.append("PCC: %s"%(self.pcc))
        return "\n".join(v)


class CheriPermissionBits(Enum):
    Global = 1 << 0
    Execute = 1 << 1
    Load = 1 << 2
    Store = 1 << 3
    LoadCap = 1 << 4
    StoreCap = 1 << 5
    StoreLocalCap = 1 << 6
    Seal = 1 << 7
    CCall = 1 << 8
    Unseal = 1 << 9
    AccessSystemRegs = 1 << 10

    def __or__(self, other) -> int:
        if isinstance(other, CheriPermissionBits):
            return self.value | other.value
        return self.value | other


class MipsStatus(object):
    CHERI_C27_TO_31_INACESSIBLE = False  # type: bool

    '''Represents the status of the MIPS CPU registers, populated by parsing
    a log file. If x is a MipsStatus object, registers can be accessed by name
    as x.<REGISTER_NAME> or number as x[<REGISTER_NUMBER>].'''
    def __init__(self, fh):
        self.fh = fh
        self.threads = defaultdict(ThreadStatus)  # type: typing.Dict[int, ThreadStatus]
        self.parse_log()
        if not len(self.threads):
            raise MipsException("No reg dump found in %s"%self.fh)
        if self.pc is None:
            raise MipsException("Failed to parse PC from %s"%self.fh)

    def parse_log(self):
        '''Parse a log file and populate self.reg_vals and self.pc'''
        thread = 0
        for line in self.fh:
            # TODO: this parses a lot of useless data. It might be better to start reading from the end of the file...
            # All regexes but one start with "DEBUG " so skip any lines that don't
            # start with DEBUG to save time and don't call line.strip()
            if not line.startswith("DEBUG "):
                # The only exception is the THREAD_RE:
                line = line.strip()
                if line.endswith("======"):
                    thread_groups = THREAD_RE.search(line)
                    if thread_groups:
                        thread = int(thread_groups.group(1))
                continue

            line = line.strip()  # strip leading whitespace
            # First check for the MIPS regexes:
            if line.startswith("DEBUG MIPS"):
                # We use 'thread' for both thread id and core id.
                # This will need fixing if we ever have a CPU with both
                # multiple threads and multiple cores.
                core_groups = MIPS_CORE_RE.search(line)
                if core_groups:
                    thread = int(core_groups.group(1))
                    continue
                reg_groups = MIPS_REG_RE.search(line)
                if reg_groups:
                    reg_num = int(reg_groups.group(1))
                    reg_val_hex = reg_groups.group(2)
                    reg_val = int(reg_val_hex, 16)
                    t = self.threads[thread]
                    t.reg_vals[reg_num] = HexInt(reg_val)
                    continue
                pc_groups = MIPS_PC_RE.search(line)
                if pc_groups:
                    reg_val = int(pc_groups.group(1), 16)
                    t = self.threads[thread]
                    t.pc = HexInt(reg_val)
                    continue
            elif line.startswith("DEBUG CAP"):
                cap_core_groups = CAPMIPS_CORE_RE.search(line)
                if cap_core_groups:
                    thread = int(cap_core_groups.group(1))
                    continue
                cap_reg_groups = CAPMIPS_REG_RE.search(line)
                if cap_reg_groups:
                    cap_reg_num = int(cap_reg_groups.group(1))
                    t = self.threads[thread]
                    t.cp2[cap_reg_num] = capabilityFromStrings(*cap_reg_groups.groups()[1:8])
                    continue
                cap_hwreg_groups = CAPMIPS_HWREG_RE.search(line)
                if cap_hwreg_groups:
                    cap_reg_num = int(cap_hwreg_groups.group(1))
                    t = self.threads[thread]
                    t.cp2_hwregs[cap_reg_num] = capabilityFromStrings(*cap_hwreg_groups.groups()[2:9])
                    continue
                cap_pc_groups = CAPMIPS_PC_RE.search(line)
                if cap_pc_groups:
                    t = self.threads[thread]
                    t.pcc = capabilityFromStrings(*cap_pc_groups.groups()[0:7])
                    continue


    # For code completion
    @property
    def c1(self) -> Capability: return self.threads[0].cp2[1]
    @property
    def c2(self) -> Capability: return self.threads[0].cp2[2]
    @property
    def c3(self) -> Capability: return self.threads[0].cp2[3]
    @property
    def c4(self) -> Capability: return self.threads[0].cp2[4]
    @property
    def c5(self) -> Capability: return self.threads[0].cp2[5]
    @property
    def c6(self) -> Capability: return self.threads[0].cp2[6]
    @property
    def c7(self) -> Capability: return self.threads[0].cp2[7]
    @property
    def c8(self) -> Capability: return self.threads[0].cp2[8]
    @property
    def c9(self) -> Capability: return self.threads[0].cp2[9]
    @property
    def c10(self) -> Capability: return self.threads[0].cp2[10]
    @property
    def c11(self) -> Capability: return self.threads[0].cp2[11]
    @property
    def c12(self) -> Capability: return self.threads[0].cp2[12]
    @property
    def c13(self) -> Capability: return self.threads[0].cp2[13]
    @property
    def c14(self) -> Capability: return self.threads[0].cp2[14]
    @property
    def c15(self) -> Capability: return self.threads[0].cp2[15]
    @property
    def c16(self) -> Capability: return self.threads[0].cp2[16]
    @property
    def c17(self) -> Capability: return self.threads[0].cp2[17]
    @property
    def c18(self) -> Capability: return self.threads[0].cp2[18]
    @property
    def c19(self) -> Capability: return self.threads[0].cp2[19]
    @property
    def c20(self) -> Capability: return self.threads[0].cp2[20]
    @property
    def c21(self) -> Capability: return self.threads[0].cp2[21]
    @property
    def c22(self) -> Capability: return self.threads[0].cp2[22]
    @property
    def c23(self) -> Capability: return self.threads[0].cp2[23]
    @property
    def c24(self) -> Capability: return self.threads[0].cp2[24]
    @property
    def c25(self) -> Capability: return self.threads[0].cp2[25]
    @property
    def c26(self) -> Capability: return self.threads[0].cp2[26]
    @property
    def c27(self) -> Capability: return self.threads[0].cp2[27]
    @property
    def c28(self) -> Capability: return self.threads[0].cp2[28]
    @property
    def c29(self) -> Capability: return self.threads[0].cp2[29]
    @property
    def c30(self) -> Capability: return self.threads[0].cp2[30]
    @property
    def c31(self) -> Capability: return self.threads[0].cp2[31]

    # Named registers:
    @property
    def idc(self) -> Capability: return self.threads[0].idc
    @property
    def ddc(self) -> Capability: return self.threads[0].ddc
    @property
    def kcc(self) -> Capability: return self.threads[0].kcc
    @property
    def kdc(self) -> Capability: return self.threads[0].kdc
    @property
    def epcc(self) -> Capability: return self.threads[0].epcc
    @property
    def error_epcc(self) -> Capability: return self.threads[0].error_epcc

    @property
    def cp2(self):
        return self.threads[0].cp2

    def __getattr__(self, key):
        '''Return a register value by name. For backwards compatibility this defaults to thread zero.'''
        return getattr(self.threads[0], key)

    def __getitem__(self, key):
        '''Return a register value by number. For backwards compatibility this defaults to thread zero.'''
        return self.threads[0][key]

    def __repr__(self):
        return "<MipsStatus from " + repr(self.fh.name) + ">"
        # v = []
        # for i, t in self.threads.items():
        #     v.append("======  Thread %3d  ======" % i)
        #     v.append(t.__repr__())
        # return "\n".join(v)

    class Cause(Enum):
        TLB_Mod = 1
        TLB_Load = 2
        TLB_Store = 3
        AdEL = 4
        AdES = 5
        IBUS = 6
        DBUS = 7
        SYSCALL = 8
        BREAK = 9
        ReservedInstruction = 10
        COP_Unusable = 11
        OVERFLOW = 12
        TRAP = 13
        FPE = 15
        COP2 = 18

        @staticmethod
        def fromint(value):
            if isinstance(value, MipsStatus.Cause):
                return "<Cause " + value.name + " (" + str(value.value) + ")>"
            for e in MipsStatus.Cause:
                if value == e.value:
                    return "<Cause " + e.name + " (" + str(value) + ")>"
            return "<unknown Cause " + str(value) + ">"

    # See "Table 4.2: Capability Exception Codes" in the CHERI reference
    class CapCause(Enum):
        NONE = 0x00
        Length_Violation = 0x01
        Tag_Violation = 0x02
        Seal_Violation = 0x03
        Type_Violation = 0x04
        Call_Trap = 0x05
        Return_Trap = 0x06
        Trusted_Stack_Underflow = 0x07
        User_Permission_Violation = 0x08
        TLB_Store_Capability_Violation = 0x09
        Bounds_Not_Exactly_Representable = 0x0a
        # reserved = 0x0b
        # reserved = 0x0c
        # reserved = 0x0d
        # reserved = 0x0e
        # reserved = 0x0f
        Global_Violation = 0x10
        Permit_Execute_Violation = 0x11
        Permit_Load_Violation = 0x12
        Permit_Store_Violation = 0x13
        Permit_Load_Capability_Violation = 0x14
        Permit_Store_Capability_Violation = 0x15
        Permit_Store_Local_Capability_Violation = 0x16
        Permit_Seal_Violation = 0x17
        Access_System_Registers_Violation = 0x18
        Permit_CCall_Violation = 0x19
        Access_CCall_IDC_Violation = 0x1a
        Permit_Unseal_Violation = 0x1b
        # reserved = 0x1c
        # reserved = 0x1d
        # reserved = 0x1e
        # reserved = 0x1f

        @staticmethod
        def fromint(value):
            if isinstance(value, MipsStatus.CapCause):
                return "<CapCause " + value.name + " (" + str(value.value) + ")>"
            for e in MipsStatus.CapCause:
                if value == e.value:
                    return "<CapCause " + e.name + " (" + str(value) + ")>"
            return "<unknown CapCause " + str(value) + ">"

MIPS_ICACHE_TAG_RE=FasterRegex('DEBUG ICACHE TAG ENTRY', r'\s*([0-9]+) Valid=([01]) Tag value=([0-9a-fA-F]+)$')

class ICacheException(Exception):
    pass

class ICacheTag(object):
    def __init__(self, index, valid, value):
        self.index = int(index)
        self.valid = (valid == '1')
        self.value = int(value,16)

    def __repr__(self):
        return 'idx:%3d valid:%r value:0x%x'%(self.index, self.valid, self.value)

class ICacheStatus(object):
    '''Represents the status of the Instruction Cache, populated by parsing
    a log file. If x is a ICacheStatus object, tags can be accessed by name
    as x.[TAG_INDEX].'''
    def __init__(self, fh):
        self.fh = fh
        self.start_pos = self.fh.tell()
        self.icache_tags = [None] * 512
        self.parse_log()
        for i in range(512):
            if self.icache_tags[i] is None:
                raise ICacheException("Failed to parse icache tag %d from %s"%(i,self.fh))

    def parse_log(self):
        '''Parse a log file and populate self.icache_tags'''
        for line in self.fh:
            line = line.strip()
            icache_groups = MIPS_ICACHE_TAG_RE.search(line)
            if (icache_groups):
                tag_idx = int(icache_groups.group(1))
                self.icache_tags[tag_idx] = ICacheTag(*icache_groups.groups()[0:3])

    def __getitem__(self, key):
        '''Return a tag by index'''
        if not type(key) is int or key < 0 or key > 511:
            raise ICacheException("Not a valid tag index", key)
        return self.icache_tags[key]

    def __repr__(self):
        v = []
        for i in range(len(self.icache_tags)):
            v.append("%r\n"%(self.icache_tags[i]))
        return "\n".join(v)
