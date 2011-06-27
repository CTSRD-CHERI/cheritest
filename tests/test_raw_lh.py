from bsim_utils import BaseBsimTestCase

class raw_lh(BaseBsimTestCase):
    def test_a0(self):
        '''Test unsigned load half word from double word'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfedc, "Unsigned half word load from double word failed")

    def test_a1(self):
        '''Test signed-extended positive load half word'''
        self.assertRegisterEqual(self.MIPS.a1, 0x7fff, "Sign-extended positive half word load failed")

    def test_a2(self):
        '''Test signed-extended negative load half word'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff, "Sign-extended negative half word load failed")

    def test_a3(self):
        '''Test unsigned positive load half word'''
        self.assertRegisterEqual(self.MIPS.a3, 0x7fff, "Unsigned positive half word load failed")

    def test_a4(self):
        '''Test unsigned negative load half word'''
        self.assertRegisterEqual(self.MIPS.a4, 0xffff, "Unsigned negative half word load failed")

    def test_pos_offset(self):
        '''Test half word load at positive offset'''
        self.assertRegisterEqual(self.MIPS.a5, 2, "Half word load at positive offset failed")

    def test_neg_offset(self):
        '''Test half word load at negative offset'''
        self.assertRegisterEqual(self.MIPS.a6, 1, "Half word load at negative offset failed")
