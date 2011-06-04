from bsim_utils import BaseBsimTestCase

class raw_reg_init(BaseBsimTestCase):
    def test_reg_init(self):
        '''Test that state of all registers is zero on CPU init'''
        for i in range(32):
            self.assertRegisterExpected(i, 0)
