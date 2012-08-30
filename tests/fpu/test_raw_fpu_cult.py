from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_cult(BaseCHERITestCase):
    def test_cult(self):
        '''Test we can compare unordered or less than'''
        self.assertRegisterEqual(self.MIPS.s0, 0x1, "Failed to compare unordered or less than 1.0, 2.0 in single precision");
        self.assertRegisterEqual(self.MIPS.s1, 0x1, "Failed to compare unordered or less than 1.0, 2.0 in in double precision");
        self.assertRegisterEqual(self.MIPS.s2, 0x1, "Failed to compare unordered or less than 2.0, 1.0 and 1.0, 2.0 in paired single precision");
        self.assertRegisterEqual(self.MIPS.s3, 0x0, "Failed to compare unordered or less than 2.0, 2.0 in single precision");
        self.assertRegisterEqual(self.MIPS.s4, 0x0, "Failed to compare unordered or less than 2.0, 2.0 in double precision");
        self.assertRegisterEqual(self.MIPS.s5, 0x0, "Failed to compare unordered or less than 2.0, 1.0 and 2.0, 1.0 in paired single precision");
        self.assertRegisterEqual(self.MIPS.s6, 0x1, "Failed to compare unordered or less than 2.0, QNaN in single precision");
        self.assertRegisterEqual(self.MIPS.s7, 0x1, "Failed to compare unordered or less than QNaN, QNaN in double precision");
        self.assertRegisterEqual(self.MIPS.a0, 0x1, "Failed to compare unordered or less than 0, QNaN and 0, QNaN in paired single precision");
        self.assertRegisterEqual(self.MIPS.a1, 0x0, "Failed to compare unordered or less than 2.0, 2.0 in single precision");
        self.assertRegisterEqual(self.MIPS.a2, 0x0, "Failed to compare unordered or less than 1.0, 2.0 in double precision");
        self.assertRegisterEqual(self.MIPS.a3, 0x2, "Failed to compare unordered or less than 1.0, 2.0 and 2.0, 1.0 in paired single precision");
