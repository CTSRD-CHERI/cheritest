from bsim_utils import BaseBsimTestCase

class test_mul_div_loop(BaseBsimTestCase):
    def test_a0(self):
        '''Test that result of multiply and divide loop test is correct.'''
        self.assertRegisterEqual(self.MIPS.s7, 0x0000000000058980, "Final Multiply Result is Incorrect")
        self.assertRegisterEqual(self.MIPS.t8, 0x0000000000009D80, "Final Divide Result is Incorrect")

# mul result: 0000000000058980
# div result: 0000000000009D80
