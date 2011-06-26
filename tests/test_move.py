from bsim_utils import BaseBsimTestCase

class test_move(BaseBsimTestCase):
    def test_move(self):
        '''Check that intended 64-bit value is in t2'''
        self.assertRegisterEqual(self.MIPS.t2, 0xfedcba9876543210, "Register assignment failed")
