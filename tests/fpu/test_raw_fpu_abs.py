from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_abs(BaseCHERITestCase):
    def test_abs(self):
        '''Test we can take absolute values'''
        self.assertRegisterEqual(self.MIPS.s0, 0x07FF000000000000, "Failed to take absolute of double")
        self.assertRegisterEqual(self.MIPS.s1, 0x0FFF0000, "Failed to take absolute of single")
        self.assertRegisterEqual(self.MIPS.s2, 0x3F80000040000000, "Failed to take absolute of paired single")

    def test_abs_edge_cases(self):
        self.assertRegisterEqual(self.MIPS.s3, 0x7F81000040000000, "Failed to echo QNaN")
        self.assertRegisterEqual(self.MIPS.s4, 0x0, "Failed to flush denormalised result")
