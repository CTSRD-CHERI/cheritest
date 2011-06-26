from bsim_utils import BaseBsimTestCase

class raw_sh(BaseBsimTestCase):
    def test_a0(self):
        '''Test unsigned load of stored half word from double word'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfedc, "Unsigned load of half word from double word failed")

    def test_a1(self):
        '''Test signed load of stored positive half word'''
        self.assertRegisterEqual(self.MIPS.a1, 1, "Sign-extended load of positive half word failed")

    def test_a2(self):
        '''Test signed load of stored negative half word'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff, "Sign-extended load of negative half word failed")

    def test_a3(self):
        '''Test unsigned load of stored positive half word'''
        self.assertRegisterEqual(self.MIPS.a3, 1, "Unsigned load of positive half word failed")

    def test_a4(self):
        '''Test unsigned load of stored negative half word'''
        self.assertRegisterEqual(self.MIPS.a4, 0xffff, "Unsigned load of negative half word failed")

