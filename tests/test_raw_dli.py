from bsim_utils import BaseBsimTestCase

class raw_dli(BaseBsimTestCase):
    def test_reg_values(self):
        '''Test dli instruction across all general-purpose registers'''
        for i in range(32):
            self.assertRegisterExpected(i, i, "Register load immediate failed")
