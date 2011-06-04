from bsim_utils import BaseBsimTestCase

class raw_reg_load_immediate(BaseBsimTestCase):
    def test_load_immediate(self):
        '''Test load immediate instruction'''
        for i in range(32):
            self.assertRegisterExpected(i, i)
