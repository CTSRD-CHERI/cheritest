#!/usr/bin/env python3
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

import collections
import functools
import unittest
import os
import os.path
import inspect
import pytest

try:
    import typing
except ImportError:
    typing = {}

from tools.sim import *


def xfail_on(var, reason=""):
    '''
    If the env var TEST_MACHINE matches var the test will be marked as xfail
    Useful if certain features have not been implemented yet
    :param var: the machine where this test is expected to fail (e.g. "qemu"
    :return:
    '''
    reason_str = "Not supported on " + pytest.config.option.TEST_MACHINE.lower() + ": "
    if reason:
        reason_str += ": " + reason
    return pytest.mark.xfail(pytest.config.option.TEST_MACHINE.lower() == var.lower(),
                             reason=reason_str)


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
                setattr(test, k, pytest.mark.xfail(reason="Not support with GNU binutils")(v))
        return test
    else:
        assert callable(test)
        return pytest.mark.xfail(reason="Not support with GNU binutils")


# TODO: use an enum to ensure only known features are added as @attr

# This contains all the unsupported features (e.g. "capabilies", "float64", etc.)

def is_feature_supported(feature, value=None):
    if value is None:
        return not _is_feature_any_value_unsupported(feature)
    else:
        return not _is_feature_value_unsupported(feature, value)


def _is_feature_any_value_unsupported(feature):
    return feature in pytest.config.CHERITEST_UNSUPPORTED_FEATURES


def _is_feature_value_unsupported(feature, value) -> int:
    is_unsupported_list = pytest.config.CHERITEST_UNSUPPORTED_FEATURES.get(feature, list())
    if value in is_unsupported_list:
        return 1
    elif "ALWAYS" in is_unsupported_list:
        return 2
    return 0


def attr(*args, **kwargs):
    def wrap_test_fn(ob):
        return ob

    # import pprint
    # pprint.pprint(vars(pytest.config.option))
    for feature in args:
        if _is_feature_any_value_unsupported(feature):
            return pytest.mark.skip("Feature '" + feature + "' is not supported!")
    for feature, value in kwargs.items():
        unsupported_kind = _is_feature_value_unsupported(feature, value)
        if unsupported_kind == 1:
            return pytest.mark.skip("Feature '" + feature + "' value '" + value + "' is not supported!")
        if unsupported_kind == 2:
            return pytest.mark.skip("Feature '" + feature + "' value '" + value +
                                    "' is not supported (feature is completely unsupported)!")
    return wrap_test_fn


class BaseBERITestCase(unittest.TestCase):
    '''Abstract base class for test cases for the BERI CPU running under BSIM.
    Concrete subclasses may override class variables LOG_DIR (for the location
    of the log directory, defaulting to "log") and LOG_FN (for the name of the
    log file within LOG_DIR, defaulting to the class name appended with
    ".log"). Subclasses will be provided with the class variable MIPS, containing
    an instance of MipsStatus representing the state of the BERI CPU.'''

    LOG_DIR = os.environ.get("LOGDIR", "log")
    LOG_FN = None
    MIPS_EXCEPTION = None
    ## Trigger a test failure (for testing the test-cases)
    ALWAYS_FAIL = is_envvar_true("DEBUG_ALWAYS_FAIL")
    EXPECT_EXCEPTION = None

    cached = bool(int(os.environ.get("CACHED", "0")))
    multi = bool(int(os.environ.get("MULTI1", "0")))

    @property
    def TEST_MACHINE(self):
        return pytest.config.option.TEST_MACHINE.lower()

    def __init__(self, *args, **kwargs):
        super(BaseBERITestCase, self).__init__(*args, **kwargs)
        self._MIPS = None  # type: MipsStatus
        self.unexpected_exception = False
        self._SETUP_EXCEPTION = None

    def _do_setup(self):
        '''Parse the log file and instantiate MIPS'''
        assert self.cached is not None
        assert self.multi is not None
        # The test class name should be the same as the test class file minus .py
        # TODO: we could relax this restriction now that we know how to get
        # the file name for the file containing the test defintion and just
        # always use that
        class_defintion_file = inspect.getfile(self.__class__)
        expected_class_name = os.path.basename(class_defintion_file)
        # remove .py
        expected_class_name = os.path.splitext(expected_class_name)[0]
        class_name = self.__class__.__name__
        self.assertEqual(expected_class_name, class_name,
                         "Invalid python test class name, it should match the file name")

        if self.LOG_FN is None:
            if self.multi and self.cached:
                self.LOG_FN = self.__class__.__name__ + "_cachedmulti.log"
            elif self.multi:
                self.LOG_FN = self.__class__.__name__ + "_multi.log"
            elif self.cached:
                self.LOG_FN = self.__class__.__name__ + "_cached.log"
            else:
                self.LOG_FN = self.__class__.__name__ + ".log"
        assert self._MIPS is None
        try:
            if self.EXPECT_EXCEPTION is not None:
                expect_exception = self.EXPECT_EXCEPTION
            else:
                # raw tests don't have the default exception handler so don't check for exceptions
                expect_exception = 'raw' in class_name or "_x_" in class_name
            self.parseLog(os.path.join(self.LOG_DIR, self.LOG_FN), expect_exception)
        except Exception as e:
            self._SETUP_EXCEPTION = e

    def parseLog(self, filename, expect_exception=False):
        with open(filename, "rt") as fh:
            self._MIPS = MipsStatus(fh)
            # The test framework has a default exception handler which
            # increments k0 and returns to the instruction after the
            # exception. We assert that k0 is zero here to check there
            # weren't any unexpected exceptions. The EXPECT_EXCEPTION
            # class variable can be overridden in subclasses (set to
            # True or False), but actually all tests which expect
            # exceptions have custom handlers so none of them need to.
            if self._MIPS.k0 != 0 and not expect_exception:
                self.MIPS_EXCEPTION = Exception(self.__class__.__name__ + " threw " +
                                                str(self._MIPS.k0) + " exception(s) unexpectedly")
                self.unexpected_exception = True
                raise self.MIPS_EXCEPTION

    @property
    def MIPS(self):
        # type: () -> MipsStatus
        if self._MIPS is None:
            self._do_setup()
            assert self._SETUP_EXCEPTION is None, str(self._SETUP_EXCEPTION)
            assert self.unexpected_exception is False, str(self.MIPS_EXCEPTION)
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
        # mips_regs = self.MIPS  # force setup of the whole class
        # assert mips_regs is not None
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
        perm_size = int(pytest.config.option.PERM_SIZE)
        if perm_size == 31:
            return 0x7fff87ff
        elif perm_size == 23:
            return 0x7f87ff
        elif perm_size == 15:
            return 0x787ff
        assert False, "Invalid perm size %d" % perm_size

    @property
    def max_nonexec_perms(self):
        return self.max_permissions & ~2

    @property
    def max_nostore_perms(self):
        return self.max_permissions & ~(8 | 32)


    @property
    def max_length(self):
        return 0xffffffffffffffff

    def assertRegisterAllPermissions(self, reg_val, msg=None):
        self.assertCapPermissions(reg_val, self.max_permissions, msg)

    def assertCapPermissions(self, reg_val, expected, msg=None):
        # Allow passing either the permissions value or a cap reg:
        if isinstance(reg_val, Capability):
            reg_val = reg_val.perms
        if self.ALWAYS_FAIL or reg_val != expected:
            if msg is None:
                msg = ""
            else:
                msg = msg + ": "
            self.fail(msg + "permissions 0x%016x != 0x%016x" % (reg_val, expected))

    def assertNullCap(self, cap, msg=""):
        self._assertInvalidCap(cap, offset=0, msg=msg)

    def assertIntCap(self, cap, int_value, msg=""):
        self._assertInvalidCap(cap, offset=int_value, msg=msg)

    def _assertInvalidCap(self, cap, offset=0, msg=""):
        # type: (Capability, str) -> None
        msg += (" " if msg else "")
        msg += "(cap=<" + str(cap) + ">)\nshould be "
        if offset == 0:
            msg += "null but "
        else:
            msg += "an untagged integer value but "
        self.assertRegisterEqual(cap.t     , 0, msg + "tag set")
        self.assertRegisterEqual(cap.s     , 0, msg + "is sealed")
        self.assertRegisterEqual(cap.ctype , 0, msg + "has nonzero otype")
        self.assertRegisterEqual(cap.perms , 0, msg + "has nonzero perms")
        self.assertRegisterEqual(cap.offset, offset, msg + "has wrong offset")
        self.assertRegisterEqual(cap.base  , 0, msg + "has nonzero base")
        self.assertRegisterEqual(cap.length, self.max_length, msg + "has non-compliant length")

    def assertDefaultCap(self, cap, msg="", offset=0, perms=None):
        # type: (Capability, str, int) -> None
        self.assertValidCap(cap, msg, offset=offset, base=0, length=self.max_length, perms=perms,
                            check_msg="default cap")

    def assertCapabilitiesEqual(self, cap1, cap2, msg=""):
        # type: (Capability, Capability, str) -> None
        assert cap1 == cap2, msg

    def assertValidCap(self, cap, msg="", base=0, length=0, offset=0, perms=None, check_msg=None):
        msg += " " if msg else ""
        if check_msg is None:
            check_msg = "valid cap"
            if not isinstance(offset, collections.Iterable) and offset != 0:
                check_msg += " with offset 0x%x" % offset
        msg += "(cap=<" + str(cap) + ">)\nshould be " + check_msg + " but "
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

    def assertCompressedTrapInfo(self, capreg, mips_cause=-1, cap_cause=None,
                                 cap_reg=None, trap_count=None, no_trap=False,
                                 bdelay=False, msg=""):
        # type: (BaseBERITestCase, Capability, int, int, int, int, bool, str) -> None
        '''
        :param capreg: The register containing the compressed exception info
                       (see save_counting_exception_handler_cause in macros.s)
        :param mips_cause: the expected self.MIPS.Cause.* value or None
        :param cap_cause:  The expected cself.MIPS.CapCause.* value or None
        :param cap_reg:    The expected capreg or None
        :param trap_count: The expected number of traps so far or None if it doesn't matter
        :param no_trap: If true then we expect the exception handler to not have been triggered
                        (Note: The test should invoke clear_counting_exception_handler_regs)
        :param bdelay: whether the cause register should have the branchdelay flag set or None if it doesn't matter
        :param msg: Additional message to print on failure
        :return:
        '''
        if no_trap:
            if isinstance(capreg, Capability):
                self.assertNullCap(capreg, msg=msg + " (didn't expect a trap here)")
            else:
                self.assertRegisterEqual(capreg, 0, msg=msg + " (didn't expect a trap here)")
            return

        compressed_value = capreg.offset if isinstance(capreg, Capability) else capreg
        # See macros.s for the layout of the offset field
        # Extract cause (bits 18-23)
        cause_value = (compressed_value >> 18) & 0x1f
        if cause_value != mips_cause:
            self.fail(msg + ": MIPS cause wrong: %s != expected %s" % (
                MipsStatus.Cause.fromint(cause_value), MipsStatus.Cause.fromint(mips_cause)))
        if bdelay is not None:
            bdelay_value = bool((compressed_value >> 47) & 1)
            self.assertEqual(bdelay_value, bdelay, msg + ": BDELAY CAUSE flag wrong: expected trap" +
                             ("" if bdelay else " NOT ") + " in delay slot")

        if cap_reg is not None:
            value = compressed_value & 0xff  # CapCause.RegNum in Bits 0-7
            self.assertRegisterEqual(value, cap_reg, msg + ": cap reg wrong")
        if cap_cause is not None:
            value = (compressed_value >> 8) & 0xff  # CapCause.Cause is Bits 8-15
            if value != cap_cause:
                self.fail(msg + ": cap cause wrong: %s != expected %s" % (
                    MipsStatus.CapCause.fromint(value), MipsStatus.CapCause.fromint(cap_cause)))
        if trap_count is not None:
            value = compressed_value >> 48  # Bits 48-63
            self.assertRegisterEqual(value, trap_count, msg + ": trap count wrong")

    def assertCp2Fault(self, info, cap_cause, cap_reg=None, trap_count=None, bdelay=False, msg=""):
        # type: (BaseBERITestCase, Capability, int, int, int, str) -> None
        """
            Check that capreg holds compressed trap info
        """
        self.assertCompressedTrapInfo(info, mips_cause=MipsStatus.Cause.COP2,
                                      cap_cause=cap_cause, cap_reg=cap_reg,
                                      trap_count=trap_count, bdelay=bdelay, msg=msg)



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
    def _get_exception_message(sim_status, exit_code, test_file):
        line_number = sim_status[4]  # load the assertion line number from $a0
        exception_count = sim_status[26]  # exception count should be in $k0

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
        return exception_message

    @staticmethod
    def verify_clang_test(sim_log, test_name, test_file):
        sim_status = MipsStatus(sim_log)
        exit_code = sim_status[2]  # load the assertion failure kind from $v0
        if exit_code == 0:
            return
        exception_message = TestClangBase._get_exception_message(sim_status, exit_code, test_file)
        assert False, exception_message

    @staticmethod
    def get_line(test_file, line_number):
        with open(os.path.join(test_file)) as src_file:
            return src_file.readlines()[line_number - 1].strip()


# Wrap the test base classes inside another class to avoid running them
# See https://stackoverflow.com/a/25695512/894271
class BERITestBaseClasses:
    class UnalignedLoadStoreTestCase(BaseBERITestCase):
        is_load_or_store = None
        expected_load_value = None

        def _do_setup(self):
            self.assertIsNotNone(self.is_load_or_store, "Must define class variable is_load_or_store")
            self.assertIn(self.is_load_or_store, ("load", "store"),
                          "Class variable is_load_or_store must be 'load' or 'store'")
            if self.is_load_or_store == "load":
                self.assertIsNotNone(self.expected_load_value, "Must define class variable expected_load_value")
            super(BERITestBaseClasses.UnalignedLoadStoreTestCase, self)._do_setup()

        def test_returned(self):
            self.assertRegisterEqual(self.MIPS.a1, 1, "flow broken by " + self.is_load_or_store + " instruction")

        @attr('trap_unaligned_ld_st')
        def test_epc(self):
            self.assertRegisterEqual(self.MIPS.a0, self.MIPS.a5, "Unexpected EPC")

        @attr('trap_unaligned_ld_st')
        def test_handled(self):
            self.assertRegisterEqual(self.MIPS.a2, 1, "sd exception handler not run")

        @attr('trap_unaligned_ld_st')
        def test_exl_in_handler(self):
            self.assertRegisterEqual((self.MIPS.a3 >> 1) & 0x1, 1, "EXL not set in exception handler")

        @attr('trap_unaligned_ld_st')
        def test_cause_bd(self):
            self.assertRegisterEqual((self.MIPS.a4 >> 31) & 0x1, 0, "Branch delay (BD) flag improperly set")

        @attr('trap_unaligned_ld_st')
        def test_cause_code(self):
            if self.is_load_or_store == "load":
                kind = "AdEL"
                code = 4
            elif self.is_load_or_store == "store":
                kind = "AdES"
                code = 5
            else:
                self.fail("not initialized correctly")
            self.assertRegisterEqual((self.MIPS.a4 >> 2) & 0x1f, code, "Code not set to " + kind)

        @attr('trap_unaligned_ld_st')
        def test_not_exl_after_handler(self):
            self.assertRegisterEqual((self.MIPS.a6 >> 1) & 0x1, 0, "EXL still set after ERET")

        @attr('trap_unaligned_ld_st')
        def test_badvaddr(self):
            self.assertRegisterEqual(self.MIPS.a7, self.MIPS.s0, "BadVAddr equal to Unaligned Address")

        @attr('allow_unaligned')
        def test_unaligned_loads_ok(self):
            if self.is_load_or_store == "load":
                self.assertRegisterEqual(self.MIPS.a7, self.expected_load_value, "Loaded value is wrong!")
            else:
                self.assertRegisterEqual(self.MIPS.a7, 42, "BadVAddr should not have been set")
            # Check that a2 - a6 haven't changed
            self.assertRegisterEqual(self.MIPS.a2, 0, "exception should not have been triggered")
            self.assertRegisterEqual(self.MIPS.a3, 0, "exception should not have been triggered")
            self.assertRegisterEqual(self.MIPS.a4, 0, "exception should not have been triggered")
            self.assertRegisterEqual(self.MIPS.a5, 0, "exception should not have been triggered")
            # TODO: should we really be testing this?
            self.assertRegisterEqual(self.MIPS.a6, 0x640080e1, "Wrong status value")


def main():
    import sys
    if len(sys.argv) != 2:
        print("Usage: %s LOGFILE" % sys.argv[0])
    regs = MipsStatus(open(sys.argv[1], "rt"))
    print(regs)


if __name__=="__main__":
    main()
