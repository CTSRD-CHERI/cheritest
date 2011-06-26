from bsim_utils import BaseBsimTestCase

class raw_lb(BaseBsimTestCase):
    def test_a0(self):
        '''Test unsigned load byte from double word'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfe, "Unsigned load from double word failed")

    def test_a1(self):
        '''Test signed-extended positive load byte'''
        self.assertRegisterEqual(self.MIPS.a1, 0x7f, "Sign-extended load of positive byte failed")

    def test_a2(self):
        '''Test signed-extended negative load byte'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff, "Sign-extended load of negative byte failed")

    def test_a3(self):
        '''Test unsigned positive load byte'''
        self.assertRegisterEqual(self.MIPS.a3, 0x7f, "Unsigned load of positive byte failed")

    def test_a4(self):
        '''Test unsigned negative load byte'''
        self.assertRegisterEqual(self.MIPS.a4, 0xff, "Unsigned load of negative byte failed")
