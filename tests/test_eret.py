from bsim_utils import BaseBsimTestCase

class test_eret(BaseBsimTestCase):
    def test_a0(self):
        '''Confirm EXL was set by test code'''
        self.assertRegisterEqual((self.MIPS.a0 >> 1) & 0x1, 1, "Unable to set EXL")

    def test_a1(self):
        '''Check that instruction before eret ran'''
        self.assertRegisterEqual(self.MIPS.a1, 1, "Instruction before ERET missed")

    def test_a2(self):
        '''Check that instruction after eret didn't run (not a branch-delay!)'''
        self.assertRegisterNotEqual(self.MIPS.a2, 2, "Instruction after ERET ran")

    def test_a3(self):
        '''Check that instruction before EPC target didn't run'''
        self.assertRegisterNotEqual(self.MIPS.a3, 3, "Instruction before EPC target ran")

    def test_a4(self):
        '''Check that instruction after EPC target did run'''
        self.assertRegisterEqual(self.MIPS.a4, 4, "Instruction at EPC target missed")

    def test_a5(self):
        '''Check that eret cleared EXL'''
        self.assertRegisterEqual((self.MIPS.a5 >> 1) & 0x1, 0, "EXL not cleared by eret")
