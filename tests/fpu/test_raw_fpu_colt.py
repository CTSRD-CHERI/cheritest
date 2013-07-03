from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_colt(BaseCHERITestCase):
    def test_colt(self):
        '''Test we can compare less than'''
        self.assertRegisterEqual(self.MIPS.s0, 0x1, "Failed to compare less than 1.0, 2.0 in single precision")
        self.assertRegisterEqual(self.MIPS.s1, 0x1, "Failed to compare less than 1.0, 2.0 in in double precision")
        self.assertRegisterEqual(self.MIPS.s2, 0x1, "Failed to compare less than 2.0, 1.0 and 1.0, 2.0 in paired single precision")
        self.assertRegisterEqual(self.MIPS.s3, 0x0, "Failed to compare less than 2.0, 2.0 in single precision")
        self.assertRegisterEqual(self.MIPS.s4, 0x0, "Failed to compare less than 2.0, 2.0 in double precision")
        self.assertRegisterEqual(self.MIPS.s5, 0x0, "Failed to compare equal 2.0, 1.0 and 2.0, 1.0 in paired single precision")
        self.assertRegisterEqual(self.MIPS.s6, 0x1, "-0.8 not marked as < 1")
