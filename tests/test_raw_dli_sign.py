from bsim_utils import BaseBsimTestCase

class raw_dli_sign(BaseBsimTestCase):
    def test_li_sign(self):
        '''Test that 32-bit negative immediate is sign-extended'''
        self.assertRegisterEqual(self.MIPS.a0, 0xffffffffffffffff, "Sign-extended negative 32-bit load immediate failed")

    def test_dli_sign(self):
        '''Test that a 64-bit negative immediate is loaded properly'''
        self.assertRegisterEqual(self.MIPS.a1, 0xffffffffffffffff, "Negative 64-bit load immediate failed")
