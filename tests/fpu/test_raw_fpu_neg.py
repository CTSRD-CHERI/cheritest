from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_neg(BaseCHERITestCase):
    def test_neg(self):
        '''Test we can negate'''
        self.assertRegisterEqual(self.MIPS.s0, 0x85300000, "Failed to negate a single")
        self.assertRegisterEqual(self.MIPS.s1, 0x0220555500000000, "Failed to negate a double")
        self.assertRegisterEqual(self.MIPS.s2, 0x3F800000C0000000, "Failed to negate -1.0, 2.0 in paired single precision")

    def test_neg_edge_cases(self):
        self.assertRegisterEqual(self.MIPS.s3, 0x7F810000C0000000, "Failed to echo QNaN");
        self.assertRegisterEqual(self.MIPS.s4, 0x0, "Failed to flush denormalised result");
