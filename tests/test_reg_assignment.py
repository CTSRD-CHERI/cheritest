from bsim_utils import BaseBsimTestCase

class test_reg_assignment(BaseBsimTestCase):
    def test_t2(self):
        '''Check that intended 64-bit value is in t2'''
        self.assertRegisterEqual(self.MIPS.t2, 0xfedcba9876543210, "Register assignment failed")
