from bsim_utils import BaseBsimTestCase

class raw_load_dword(BaseBsimTestCase):
    def test_t0(self):
        '''Test load double word instruction'''
        self.assertRegisterEqual(self.MIPS.t0, 0xfedcba9876543210)
