from bsim_utils import BaseBsimTestCase

class test_slti(BaseBsimTestCase):
    def test_eq(self):
        '''set on less than immediate: equal, non-negative'''
        self.assertRegisterEqual(self.MIPS.a0, 0, "slti returned true for equal, non-negative")

    def test_gt(self):
        '''set on less than immediate: greater than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a1, 0, "slti returned true for great than, non-negative")

    def test_lt(self):
        '''set on less than immediate: less than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a2, 1, "slti returned true for less than, non-negative")

    def test_eq_sign(self):
        '''set on less than immediate: equal, negative'''
        self.assertRegisterEqual(self.MIPS.a3, 0, "slti returned true for equal, negative")

    def test_gt_sign(self):
        '''set on less than immediate: greater than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a4, 0, "slti returned true for greater than, negative")

    def test_lt_sign(self):
        '''set on less than immediate: less than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a5, 1, "slti returned true for less than, negative")
