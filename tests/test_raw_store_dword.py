from bsim_utils import BaseBsimTestCase

class raw_store_dword(BaseBsimTestCase):
    def test_t1(self):
        '''Test load of stored double word'''
        self.assertRegisterEqual(self.MIPS.t1, 0xfedcba9876543210)
