from bsim_utils import BaseBsimTestCase

class test_movz_movn(BaseBsimTestCase):
    def test_movz_true(self):
        '''Test that result of MOVZ test is correct.'''
        self.assertRegisterEqual(self.MIPS.s0, 0xFFFFFFFFFFFFFFFF, "MOVZ moved when it shouldn't have.")
    def test_movz_false(self):
        '''Test that result of MOVZ test is correct.'''
        self.assertRegisterEqual(self.MIPS.s1, 0x0000000000000001, "MOVZ did not move when it should have.")
    def test_movn_true(self):
        '''Test that result of MOVN test is correct.'''
        self.assertRegisterEqual(self.MIPS.s2, 0xFFFFFFFFFFFFFFFF, "MOVN moved when it shouldn't have.")
    def test_movn_false(self):
        '''Test that result of MOVN test is correct.'''
        self.assertRegisterEqual(self.MIPS.s1, 0x0000000000000001, "MOVN did not move when it should have.")

		
