from beritest_tools import BaseBERITestCase
from beritest_tools import attr
import os
import tools.sim
expected_uncached=[
    0x0,
    0x800000000000000,
    0x10,
    0x400000007fffeda8,
    0x9000000040000da0,
    0x400000007fffe000,
    0x40000000,
    0x100001e,
    0x100005e,
    0x909090909090909,
    0x400000007fffe0ff,
    0xfedcba9876543210,
    0x9800000040000da0,
    0xffffffffffbfffff,
    0xe0e0e0e0e0e0e0e,
    0xf0f0f0f0f0f0f0f,
    0xda0,
    0x400000007fffeda0,
    0x400000007fffeda8,
    0x400000007fffeda8,
    0x1414141414141414,
    0x1515151515151515,
    0x400000007fffe0ff,
    0x2,
    0x1818181818181818,
    0x9000000040000ba0,
    0x0,
    0x1b1b1b1b1b1b1b1b,
    0x1c1c1c1c1c1c1c1c,
    0x9000000000007fe0,
    0x9000000000008000,
    0x900000004000038c,
  ]
expected_cached=[
    0x0,
    0x800000000000000,
    0x10,
    0x400000007fffede8,
    0x9800000040000de0,
    0x400000007fffe000,
    0x40000000,
    0x100001e,
    0x100005e,
    0x909090909090909,
    0x400000007fffe0ff,
    0xfedcba9876543210,
    0x9800000040000de0,
    0xffffffffffbfffff,
    0xe0e0e0e0e0e0e0e,
    0xf0f0f0f0f0f0f0f,
    0xde0,
    0x400000007fffede0,
    0x400000007fffede8,
    0x400000007fffede8,
    0x1414141414141414,
    0x1515151515151515,
    0x400000007fffe0ff,
    0x2,
    0x1818181818181818,
    0x9800000040000bc0,
    0x0,
    0x1b1b1b1b1b1b1b1b,
    0x1c1c1c1c1c1c1c1c,
    0x9800000000007fe0,
    0x9800000000008000,
    0x98000000400003ac,
  ]
@attr('fuzz_test_regression')
class test_regfuzz_tlb_00003047(BaseBERITestCase):
  @attr('tlb')
  def test_registers_expected(self):
    cached=bool(int(os.getenv('CACHED',False)))
    expected=expected_cached if cached else expected_uncached
    for reg in range(len(tools.sim.MIPS_REG_NUM2NAME)):
      self.assertRegisterExpected(reg, expected[reg])

