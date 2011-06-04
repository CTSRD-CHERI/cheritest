from bsim_utils import BaseBsimTestCase

class raw_store_word(BaseBsimTestCase):
    def test_t1(self):
        '''Test load of stored word'''
        self.assertRegisterEqual(self.MIPS.t1, 0xfedcba98)
