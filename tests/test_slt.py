from bsim_utils import BaseBsimTestCase

class test_slt(BaseBsimTestCase):
    def test_eq(self):
        '''set on less than: equal, non-negative'''
        self.assertRegisterEqual(self.MIPS.a0, 0, "slt returned true for equal, non-negative")

    def test_gt(self):
        '''set on less than: greater than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a1, 0, "slt returned true for great than, non-negative")

    def test_lt(self):
        '''set on less than: less than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a2, 1, "slt returned true for less than, non-negative")

    def test_eq_sign(self):
        '''set on less than: equal, negative'''
        self.assertRegisterEqual(self.MIPS.a3, 0, "slt returned true for equal, negative")

    def test_gt_sign(self):
        '''set on less than: greater than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a4, 0, "slt returned true for greater than, negative")

    def test_lt_sign(self):
        '''set on less than: less than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a5, 1, "slt returned true for less than, negative")
