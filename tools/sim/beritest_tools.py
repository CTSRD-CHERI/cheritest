#!/usr/bin/python
#-
# Copyright (c) 2011 Steven J. Murdoch
# Copyright (c) 2013 Alexandre Joannou
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
from __future__ import print_function
import nose

import collections
import functools
import unittest
import os
import os.path

from tools.sim import *

def is_envvar_true(var):
    '''Return true iff the environment variable specified is defined and
    not set to "0"'''
    return os.environ.get(var, "0") != "0"


def xfail_on(var):
    '''
    If the env var TEST_MACHINE matches var the test will be marked as xfail
    Useful if certain features have not been implemented yet
    :param var: the machine where this test is expected to fail (e.g. "qemu"
    :return:
    '''
    if os.environ.get("TEST_MACHINE", "").lower() == var.lower():
        return nose_xfail_hack
    return lambda x: x


def xfail_gnu_binutils(test):
    '''
    If the env var TEST_ASSEMBLER matches "gnu" the test will be marked as xfail
    Useful if certain features have not been implemented yet
    '''
    if os.environ.get("TEST_ASSEMBLER", "").lower() != "gnu":
        return test
    if isinstance(test, type):
        for k, v in vars(test).items():
            if k.startswith("test_"):
                setattr(test, k, nose_xfail_hack(test))
        return test
    else:
        assert callable(test)
        return nose_xfail_hack(test)


# https://stackoverflow.com/questions/9613932/nose-plugin-for-expected-failures
def nose_xfail_hack(test):
    @functools.wraps(test)
    def inner(*args, **kwargs):
        try:
            test(*args, **kwargs)
        except Exception:
            raise nose.SkipTest
        else:
            raise AssertionError('Failure expected')
    return inner

class BaseBERITestCase(unittest.TestCase):
    '''Abstract base class for test cases for the BERI CPU running under BSIM.
    Concrete subclasses may override class variables LOG_DIR (for the location
    of the log directory, defaulting to "log") and LOG_FN (for the name of the
    log file within LOG_DIR, defaulting to the class name appended with
    ".log"). Subclasses will be provided with the class variable MIPS, containing
    an instance of MipsStatus representing the state of the BERI CPU.'''

    LOG_DIR = os.environ.get("LOGDIR", "log")
    LOG_FN = None
    MIPS = None
    MIPS_EXCEPTION = None
    ## Trigger a test failure (for testing the test-cases)
    ALWAYS_FAIL = is_envvar_true("DEBUG_ALWAYS_FAIL")
    EXPECT_EXCEPTION=None

    @classmethod
    def setUpClass(cls):
        '''Parse the log file and instantiate MIPS'''
        cls.cached = bool(int(os.environ.get("CACHED", "0")))
        cls.multi = bool(int(os.environ.get("MULTI1", "0")))
        if cls.LOG_FN is None:
            if cls.multi and cls.cached:
                cls.LOG_FN = cls.__name__ + "_cachedmulti.log"
            elif cls.multi:
                cls.LOG_FN = cls.__name__ + "_multi.log"
            elif cls.cached:
                cls.LOG_FN = cls.__name__ + "_cached.log"
            else:
                cls.LOG_FN = cls.__name__ + ".log"
        cls.unexpected_exception = False
        cls._MIPS = None
        try:
            cls.parseLog(os.path.join(cls.LOG_DIR, cls.LOG_FN))
        except Exception as e:
            cls._SETUP_EXCEPTION = e

    @classmethod
    def parseLog(cls, filename):
        with open(filename, "rt") as fh:
            try:
                cls._MIPS = MipsStatus(fh)
                # The test framework has a default exception handler which
                # increments k0 and returns to the instruction after the
                # exception. We assert that k0 is zero here to check there
                # weren't any unexpected exceptions. The EXPECT_EXCEPTION
                # class variable can be overridden in subclasses (set to
                # True or False), but actually all tests which expect
                # exceptions have custom handlers so none of them need to.

                if cls.EXPECT_EXCEPTION is not None:
                    expect_exception = cls.EXPECT_EXCEPTION
                else:
                    # raw tests don't have the default exception handler so don't check for exceptions
                    expect_exception =  'raw' in cls.__name__

                if cls.MIPS.k0 != 0 and not expect_exception:
                    cls.MIPS_EXCEPTION=Exception(cls.__name__ + " threw exception unexpectedly")
                    cls.unexpected_exception = True
            except MipsException as e:
                cls.MIPS_EXCEPTION = e

    @property
    def MIPS(self):
        assert self._MIPS, "Test case was not set up properly: " + str(self._SETUP_EXCEPTION)
        return self._MIPS

    def id(self):
        result = unittest.TestCase.id(self)
        if not self.cached:
            return result

        pos = result.find(".")
        assert(pos >= 0)
        return result[:pos] + "_cached" + result[pos:]

    def setUp(self):
        if self.unexpected_exception:
            self.fail(self.__class__.__name__ + " threw exception unexpectedly")
        elif self.MIPS_EXCEPTION is not None:
            raise self.MIPS_EXCEPTION

    def assertRegisterEqual(self, first, second, msg=None):
        '''Convenience method which outputs the values of first and second if
        they are not equal (preceded by msg, if given)'''
        if self.ALWAYS_FAIL:
            first=1
            second=2
        if first != second:
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "0x%016x != 0x%016x"%(first,second))

    def assertRegisterNotEqual(self, first, second, msg=None):
        '''Convenience method which outputs the values of first and second if
        they are equal (preceded by msg, if given)'''
        if self.ALWAYS_FAIL:
            first=1
            second=1
        if first == second:
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "0x%016x == 0x%016x"%(first,second))

    def assertRegisterExpected(self, reg_num, expected_value, msg=None):
        '''Check that the contents of a register, specified by its number,
        matches the expected value. If the contents do not match, output the
        register name, expected value, and actual value (preceded by msg, if
        given).'''
        if self.ALWAYS_FAIL:
            first=1
            second=2
        else:
            first=self.MIPS[reg_num]
            second=expected_value
        if first != second:
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "0x%016x (%s) != 0x%016x"%(
                first,MIPS_REG_NUM2NAME[reg_num],second))

    def assertRegisterInRange(self, reg_val, expected_min, expected_max, msg=None):
        '''Check that a register value is in a specified inclusive range. If
        not, fails the test case outputing details preceded by msg, if given.'''
        if self.ALWAYS_FAIL:
            expected_min=1
            expected_max=0
        if reg_val < expected_min or reg_val > expected_max:
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "0x%016x is outside of [0x%016x,0x%016x]"%(
                reg_val, expected_min, expected_max))

    def assertRegisterMaskEqual(self, first, mask, second, msg=None):
        '''Convenience method which outputs the values of first and second if
        they are not equal on the bits selected by the mask (preceded by msg,
        if given)'''
        if self.ALWAYS_FAIL:
            first = 1
            second = 2
            mask = 0x3
        if first & mask != second:
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "0x%016x and 0x%016x != 0x%016x"%(first, mask, second))

    def assertRegisterMaskNotEqual(self, first, mask, second, msg=None):
        '''Convenience method which outputs the values of first and second if
        they are equal on the bits selected by the mask (preceded by msg,
        if given)'''
        if self.ALWAYS_FAIL:
            first = 1
            second = 1
            mask = 0x3
        if first & mask == second:
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "0x%016x and 0x%016x == 0x%016x"%(first, mask, second))

    def assertRegisterIsSingleNaN(self, reg_val, msg=None):
        if ((reg_val & 0x7f800000 != 0x7f800000) or (reg_val & 0x7fffff == 0)):
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "0x%016x is not a NaN value"%(reg_val))

    def assertRegisterIsSingleQNaN(self, reg_val, msg=None):
        # This tests for the IEEE 754:2008 QNaN, not the legacy MIPS
        # IEEE 754:1985 QNaN
        if (reg_val & 0x7fc00000 != 0x7fc00000):
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "0x%016x is not a QNaN value"%(reg_val))

    def assertRegisterIsDoubleNaN(self, reg_val, msg=None):
        if ((reg_val & 0x7ff0000000000000 != 0x7ff0000000000000) or (reg_val & 0xfffffffffffff == 0)):
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "0x%016x is not a NaN value"%(reg_val))

    def assertRegisterIsDoubleQNaN(self, reg_val, msg=None):
        if (reg_val & 0x7ff8000000000000 != 0x7ff8000000000000):
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "0x%016x is not a QNaN value"%(reg_val))

    @property
    def max_permissions(self):
        perm_size = int(os.environ.get("PERM_SIZE", "31"))
        if perm_size == 31:
            return 0x7fffffff
        elif perm_size == 23:
            return 0x7fffff
        elif perm_size == 19:
            return 0x7ffff
        elif perm_size == 15:
            return 0x787ff
        assert False, "Invalid perm size %d" % perm_size

    @property
    def max_nonexec_perms(self):
        return self.max_permissions & ~2

    @property
    def max_length(self):
        return 0xffffffffffffffff

    def assertRegisterAllPermissions(self, reg_val, msg=None):
        self.assertCapPermissions(reg_val, self.max_permissions, msg)

    def assertCapPermissions(self, reg_val, expected, msg=None):
        if self.ALWAYS_FAIL or reg_val != expected:
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "permissions 0x%016x != 0x%016x" % (reg_val, expected))

    def assertNullCap(self, cap, msg=""):
        msg += (" " if msg else "")
        msg += "(cap=<" + str(cap) + ">)\nshould be null but "
        self.assertRegisterEqual(cap.t     , 0, msg + "tag set")
        self.assertRegisterEqual(cap.s     , 0, msg + "is sealed")
        self.assertRegisterEqual(cap.ctype , 0, msg + "has nonzero otype")
        self.assertRegisterEqual(cap.perms , 0, msg + "has nonzero perms")
        self.assertRegisterEqual(cap.offset, 0, msg + "has nonzero offset")
        self.assertRegisterEqual(cap.base  , 0, msg + "has nonzero base")
        self.assertRegisterEqual(cap.length, self.max_length, msg + "has non-compliant length")

    def assertDefaultCap(self, cap, msg="", perms=None):
        self.assertValidCap(cap, msg, offset=0, base=0, length=self.max_length, perms=perms,
                            check_msg="default cap")

    def assertValidCap(self, cap, msg="", base=0, length=0, offset=0, perms=None, check_msg=None):
        msg += " " if msg else ""
        if check_msg is None:
            check_msg = "valid cap"
            if not isinstance(offset, collections.Iterable) and offset != 0:
                check_msg += " with offset 0x%x" % offset
        msg += "(cap=<" + str(cap) + ">)\nshould be" + check_msg + " but "
        # valid unsealed caps always have tag, !sealed, otype==0
        self.assertRegisterEqual(cap.t, 1, msg + "tag not set")
        self.assertRegisterEqual(cap.s, 0, msg + "is sealead")
        self.assertRegisterEqual(cap.ctype, 0, msg + "has nonzero otype")
        # other checks:
        if isinstance(offset, collections.Iterable):
            err = "offset not in range [0x%x,0x%x]" % (offset[0], offset[-1])
            self.assertRegisterInRange(cap.offset, offset[0], offset[-1], msg + err)
        else:
            self.assertRegisterEqual(cap.offset, offset, msg + "has wrong offset")
        self.assertRegisterEqual(cap.base, base,     msg + "has wrong base")
        self.assertRegisterEqual(cap.length, length, msg + "has wrong length")
        if perms is None or perms == self.max_permissions:
            self.assertRegisterAllPermissions(cap.perms, msg + "not all permissions set")
        else:
            self.assertCapPermissions(cap.perms, perms, msg + "has wrong permissions")

class BaseICacheBERITestCase(BaseBERITestCase):
    '''Abstract base class for test cases for the BERI Instruction Cache.'''

    LOG_DIR = os.environ.get("LOGDIR", "log")
    LOG_FN = None
    ICACHE = None
    ICACHE_EXCEPTION = None
    ## Trigger a test failure (for testing the test-cases)
    ALWAYS_FAIL = is_envvar_true("DEBUG_ALWAYS_FAIL")

    @classmethod
    def setUpClass(self):
        '''Parse the log file and instantiate MIPS'''
        super(BaseBERITestCase, self).setUpClass()
        self.cached = bool(int(os.environ.get("CACHED", "0")))
        self.multi = bool(int(os.environ.get("MULTI1", "0")))
        if self.LOG_FN is None:
            if self.multi and self.cached:
                self.LOG_FN = self.__name__ + "_cachedmulti.log"
            elif self.multi:
                self.LOG_FN = self.__name__ + "_multi.log"
            elif self.cached:
                self.LOG_FN = self.__name__ + "_cached.log"
            else:
                self.LOG_FN = self.__name__ + ".log"
        fh = open(os.path.join(self.LOG_DIR, self.LOG_FN), "rt")
        try:
            self.ICACHE = ICacheStatus(fh)
        except ICacheException as e:
            self.ICACHE_EXCEPTION = e

    def setUp(self):
        super(BaseBERITestCase, self).setUp()
        if not self.ICACHE_EXCEPTION is None:
            raise self.ICACHE_EXCEPTION

    def assertTagValid(self, tag_idx, msg=None):
        '''Convenience method which outputs the values of tag it is not valid (preceded by msg, if given)'''
        tag = self.ICACHE[tag_idx]
        if self.ALWAYS_FAIL:
            tag.valid = False
        if (tag.valid == False):
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "tag=>%r"%(tag))

    def assertTagInvalid(self, tag_idx, msg=None):
        '''Convenience method which outputs the values of tag it is valid (preceded by msg, if given)'''
        tag = self.ICACHE[tag_idx]
        if self.ALWAYS_FAIL:
            tag.valid = True
        if (tag.valid == True):
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "tag=>%r"%(tag))

    def assertTagExpectedValue(self, tag_idx, expected_value, msg=None):
        '''Check that the contents of a tag, specified by its number,
        matches the expected value. If the contents do not match, output the
        register name, expected value, and actual value (preceded by msg, if
        given).'''
        tag = self.ICACHE[tag_idx]
        if self.ALWAYS_FAIL:
            tag.valid = False
        if (tag.valid == False or tag.value != expected_value):
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "tag=>%r, expected_value=>%x"%(tag, expected_value))

    def assertTagInRange(self, tag_idx, expected_min, expected_max, msg=None):
        '''Check that a register value is in a specified inclusive range. If
        not, fails the test case outputing details preceded by msg, if given.'''
        tag = self.ICACHE[tag_idx]
        if self.ALWAYS_FAIL:
            expected_min=1
            expected_max=0
        if tag.valid == False or tag.value < expected_min or tag.value > expected_max:
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "tag=>%r, range=>[0x%016x,0x%016x]"%(tag, expected_min, expected_max))


class TestClangBase(object):
    @staticmethod
    @nose.tools.nottest
    def verify_clang_test(sim_log, test_name, test_file):
        sim_status = MipsStatus(sim_log)
        exit_code = sim_status[2]  # load the assertion failure kind from $v0
        line_number = sim_status[4]  # load the assertion line number from $a0
        exception_count = sim_status[26]  # exception count should be in $k0
        if exit_code == 0:
            return
        # -1/0xdead0000 -> general assertion failure
        if exit_code == 0xffffffffffffffff or exit_code == 0xdead0000:
            exception_message = "clang assert failed at line %d: %s" % (
                line_number, TestClangBase.get_line(test_file, line_number))
        # 0xdead0001 integer comparison failed
        elif exit_code == 0xdead0001:
            # the values are stored in a1 and a2 (registers 5 and 6)
            exception_message = "clang assert_eq long failed at line %d: %s" % (
                line_number, TestClangBase.get_line(test_file, line_number))
            dec_and_hex = lambda value: "0x%016x (%d)" % (value, value)
            exception_message += "\n>>>> Actual:   " + dec_and_hex(
                sim_status[5])
            exception_message += "\n>>>> Expected: " + dec_and_hex(
                sim_status[6])
        # 0xdead000c: integer comparison failed
        elif exit_code == 0xdead000c:
            # the values are stored in c3 and c4
            exception_message = "clang assert_eq cap failed at line %d: %s" % (
                line_number, TestClangBase.get_line(test_file, line_number))
            exception_message += "\n>>>>Actual:   " + str(
                sim_status.threads[0].cp2[3])
            exception_message += "\n>>>>Expected: " + str(
                sim_status.threads[0].cp2[4])
        elif exit_code == 0xbadc:
            exception_message = "Died due to exception"
            # TODO: regdump?
        else:
            exception_message = "unknown test exit status %d" % (exit_code)
        if exception_count != 0:
            exception_message += "\nNOTE: %d exceptions occurred, check test log!" % exception_count
        assert False, exception_message

    @staticmethod
    @nose.tools.nottest
    def get_line(test_file, line_number):
        with open(os.path.join(test_file)) as src_file:
            return src_file.readlines()[line_number - 1].strip()


def main():
    import sys
    if len(sys.argv) != 2:
        print("Usage: %s LOGFILE" % sys.argv[0])
    regs = MipsStatus(open(sys.argv[1], "rt"))
    print(regs)


if __name__=="__main__":
    main()
