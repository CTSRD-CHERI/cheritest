from bsim_utils import BaseBsimTestCase

class raw_load_hword(BaseBsimTestCase):
    def test_t0(self):
        '''Test load half word instruction'''
        self.assertRegisterEqual(self.MIPS.t0, 0xfedc)
