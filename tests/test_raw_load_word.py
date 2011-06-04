from bsim_utils import BaseBsimTestCase

class raw_load_word(BaseBsimTestCase):
    def test_t0(self):
        '''Test load word instruction'''
        self.assertRegisterEqual(self.MIPS.t0, 0xfedcba98)
