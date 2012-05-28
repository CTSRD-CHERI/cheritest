from cheritest_tools import BaseCHERITestCase
import os
import tools.sim
expected_uncached=[
    0x0,
    0x800000000000000,
    0x10,
    0x4000000080000a28,
    0x9000000040000a20,
    0x4000000080000000,
    0x40000000,
    0x100001a,
    0x100005a,
    0x909090909090909,
    0x40000000800000ff,
    0xfedcba9876543210,
    0x9800000040000a20,
    0xffffffffffbfffff,
    0xe0e0e0e0e0e0e0e,
    0xf0f0f0f0f0f0f0f,
    0xa20,
    0x4000000080000a20,
    0x4000000080000a28,
    0x4000000080000a28,
    0x1414141414141414,
    0x1515151515151515,
    0x40000000800000ff,
    0x2,
    0x1818181818181818,
    0x1919191919191919,
    0x0,
    0x1b1b1b1b1b1b1b1b,
    0x1c1c1c1c1c1c1c1c,
    0x9000000000007fe0,
    0x9000000000008000,
    0x9000000040000338,
  ]
expected_cached=[
    0x0,
    0x800000000000000,
    0x10,
    0x4000000080000a48,
    0x9800000040000a40,
    0x4000000080000000,
    0x40000000,
    0x100001a,
    0x100005a,
    0x909090909090909,
    0x40000000800000ff,
    0xfedcba9876543210,
    0x9800000040000a40,
    0xffffffffffbfffff,
    0xe0e0e0e0e0e0e0e,
    0xf0f0f0f0f0f0f0f,
    0xa40,
    0x4000000080000a40,
    0x4000000080000a48,
    0x4000000080000a48,
    0x1414141414141414,
    0x1515151515151515,
    0x40000000800000ff,
    0x2,
    0x1818181818181818,
    0x1919191919191919,
    0x0,
    0x1b1b1b1b1b1b1b1b,
    0x1c1c1c1c1c1c1c1c,
    0x9800000000007fe0,
    0x9800000000008000,
    0x9800000040000358,
  ]
class test_regfuzz_tlb_00003333(BaseCHERITestCase):
  def test_registers_expected(self):
    cached=bool(int(os.getenv('CACHED',False)))
    expected=expected_cached if cached else expected_uncached
    for reg in xrange(len(tools.sim.MIPS_REG_NUM2NAME)):
      self.assertRegisterExpected(reg, expected[reg])

