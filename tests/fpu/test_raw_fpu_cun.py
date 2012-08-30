from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_cun(BaseCHERITestCase):
    def test_cun(self):
        '''Test we can compare unordered'''
        self.assertRegisterEqual(self.MIPS.s0, 0x1, "Failed to compare unordered QNaN, QNaN in single precision");
        self.assertRegisterEqual(self.MIPS.s1, 0x1, "Failed to compare unordered QNaN, QNaN in double precision");
        self.assertRegisterEqual(self.MIPS.s2, 0x1, "Failed to compare unordered 0, QNaN and 0, QNaN in paired single precision");
        self.assertRegisterEqual(self.MIPS.s3, 0x0, "Failed to compare unordered 2.0, 2.0 in single precision");
        self.assertRegisterEqual(self.MIPS.s4, 0x0, "Failed to compare unordered 1.0, 1.0 in double precision");
        self.assertRegisterEqual(self.MIPS.s5, 0x0, "Failed to compare unordered 2.0, 1.0 and 1.0, 2.0 in paired single precision");
