from bsim_utils import BaseBsimTestCase

class raw_mul_div_loop(BaseBsimTestCase):
    def test_a0(self):
        '''Test that result of multiply and divide loop test is correct.'''
        self.assertRegisterEqual(self.MIPS.s7, 0x0000000000058980, "Final Multiply Result is Incorrect")

		
