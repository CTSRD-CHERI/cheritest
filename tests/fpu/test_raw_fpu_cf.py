from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_cf(BaseCHERITestCase):
    def test_cf(self):
        '''Test we can compare false'''
        self.assertRegisterEqual(self.MIPS.s0, 0x0, "Failed to compare false 2.0, 2.0 in single precision");
        self.assertRegisterEqual(self.MIPS.s1, 0x0, "Failed to compare false 2.0, 1.0 in double precision");
        self.assertRegisterEqual(self.MIPS.s2, 0x0, "Failed to compare false 2.0, 1.0 and 1.0, 2.0 in paired single precision");
