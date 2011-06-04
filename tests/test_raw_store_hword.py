from bsim_utils import BaseBsimTestCase

class raw_store_hword(BaseBsimTestCase):
    def test_t1(self):
        '''Test load of stored half word'''
        self.assertRegisterEqual(self.MIPS.t1, 0xfedc)
