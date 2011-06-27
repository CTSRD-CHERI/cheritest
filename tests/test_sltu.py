from bsim_utils import BaseBsimTestCase

class test_sltu(BaseBsimTestCase):
    def test_eq(self):
        '''set on less than unsigned: equal, non-negative'''
        self.assertRegisterEqual(self.MIPS.a0, 0, "sltu returned true for equal, non-negative")

    def test_gt(self):
        '''set on less than unsigned: greater than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a1, 0, "sltu returned true for great than, non-negative")

    def test_lt(self):
        '''set on less than unsigned: less than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a2, 1, "sltu returned true for less than, non-negative")

    def test_unsigned_comparison(self):
        '''set on less than unsigned: is comparison unsigned?'''
        self.assertRegisterEqual(self.MIPS.a4, 0, "sltu used signed comparison")
