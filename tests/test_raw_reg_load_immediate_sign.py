from bsim_utils import BaseBsimTestCase

class raw_reg_load_immediate_sign(BaseBsimTestCase):
    def test_li_sign(self):
        '''Test that 32-bit negative immediate is sign-extended'''
        self.assertRegisterEqual(self.MIPS.a0, 0xffffffffffffffff)

    def test_dli_sign(self):
        '''Test that a 64-bit negative immediate is loaded properly'''
        self.assertRegisterEqual(self.MIPS.a1, 0xffffffffffffffff)
