from bsim_utils import BaseBsimTestCase

class raw_load_byte(BaseBsimTestCase):
    def test_t0(self):
        '''Test load byte instruction'''
        self.assertRegisterEqual(self.MIPS.t0, 0xfe)
