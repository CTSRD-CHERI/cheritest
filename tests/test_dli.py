from bsim_utils import BaseBsimTestCase

class test_dli(BaseBsimTestCase):
    def test_li(self):
        '''Check that intended 32-bit constant turns up in t0'''
        self.assertRegisterEqual(self.MIPS.t0, 0x76543210, "32-bit register load from immediate failed")

    def test_dli(self):
        '''Check that intended 64-bit constant turns up in t1'''
        self.assertRegisterEqual(self.MIPS.t1, 0xfedcba9876543210, "64-bit register load from immediate failed")
