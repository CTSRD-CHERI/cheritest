from bsim_utils import BaseBsimTestCase

class test_reg_load_immediate(BaseBsimTestCase):
    def test_t0(self):
        '''Check that intended 32-bit constant turns up in t0'''
        self.assertRegisterEqual(self.MIPS.t0, 0x76543210)

    def test_t1(self):
        '''Check that intended 64-bit constant turns up in t1'''
        self.assertRegisterEqual(self.MIPS.t1, 0xfedcba9876543210)
