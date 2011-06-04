from bsim_utils import BaseBsimTestCase

class raw_store_byte(BaseBsimTestCase):
    def test_t1(self):
        '''Test load of stored byte'''
        self.assertRegisterEqual(self.MIPS.t1, 0xfe)
