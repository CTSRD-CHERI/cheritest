from bsim_utils import BaseBsimTestCase

class raw_arithmetic_combo(BaseBsimTestCase):
    def test_a0(self):
        '''Test that stages of the arithmetic combo test procuced the correct result.'''
        self.assertRegisterEqual(self.MIPS.s0, 0x0000002800000014, "Stage 1 Incorrect")
        self.assertRegisterEqual(self.MIPS.s1, 0x0000000000000001, "Stage 2 Incorrect")
        self.assertRegisterEqual(self.MIPS.s2, 0xffffffff9c320384, "Stage 3 Incorrect")
        self.assertRegisterEqual(self.MIPS.s3, 0x00FFFFFFFFFF1E6F, "Stage 4 Incorrect")
        self.assertRegisterEqual(self.MIPS.s4, 0xFFFFFFFFFFC3BE75, "Stage 5 Incorrect")
        self.assertRegisterEqual(self.MIPS.s5, 0x0, "Stage 6 Incorrect")
		
