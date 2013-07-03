from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_sqrt(BaseCHERITestCase):
    def test_sqrt(self):
        '''Test we can take square roots'''
        self.assertRegisterEqual(self.MIPS.s0, 0x41000000, "Failed to take the square root of 64.0 in single precision")
        self.assertRegisterEqual(self.MIPS.s1, 0x40358FD340000000, "Failed double sqrt")

    def test_sqrt_edge_cases(self):
        self.assertRegisterEqual(self.MIPS.s3, 0x7FF1000000000000, "Failed to echo QNaN");
