from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_rsqrt(BaseCHERITestCase):
    def test_rsqrt(self):
        '''Test we can take reciprocal square roots'''
        self.assertRegisterEqual(self.MIPS.s0, 0x3F000000, "Failed to take reciprocal square root of 4.0 in single precision");
        self.assertRegisterEqual(self.MIPS.s1, 0x7FF0000000000000, "Failed to take reciprocal of 0.0 in double precision");
        self.assertRegisterEqual(self.MIPS.s3, 0x7FF1000000000000, "Failed to echo QNaN");
