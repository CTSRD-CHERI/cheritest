from bsim_utils import BaseBsimTestCase

class test_sltiu(BaseBsimTestCase):
    def test_eq(self):
        '''set on less than immediate unsigned: equal, non-negative'''
        self.assertRegisterEqual(self.MIPS.a0, 0, "sltiu returned true for equal, non-negative")

    def test_gt(self):
        '''set on less than immediate unsigned: greater than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a1, 0, "sltiu returned true for great than, non-negative")

    def test_lt(self):
        '''set on less than immediate unsigned: less than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a2, 1, "sltiu returned true for less than, non-negative")

    def test_sign_extend(self):
        '''set on less than immediate unsigned: is immediate sign-extended?'''
        self.assertRegisterEqual(self.MIPS.a3, 1, "sltiu did not sign extend immediate")

    def test_unsigned_comparison(self):
        '''set on less than immediate unsigned: is comparison unsigned?'''
        self.assertRegisterEqual(self.MIPS.a4, 0, "sltiu used signed comparison")
