from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_cvtw(BaseCHERITestCase):
    def test_convert_one_to_word(self):
        '''Test we can convert 1.0f to word'''
        self.assertRegisterEqual(self.MIPS.s0, 1, "Didn't convert 1 to word")

    def test_convert_negative_to_word(self):
        '''Test we can convert -1.0f to word'''
        self.assertRegisterEqual(self.MIPS.s1, 0xFFFFFFFFFFFFFFFF, "Didn't convert -1 to word")

    def test_convert_large_to_word(self):
        '''Test we can convert 2^30 to word'''
        self.assertRegisterEqual(self.MIPS.s2, 1073741824 , "Didn't convert 2^30 to word")

    def test_convert_fraction_to_word(self):
        '''Test we can convert fractional values to word'''
        self.assertRegisterEqual(self.MIPS.s3, 107, "Didn't convert 107.325 to word")
        self.assertRegisterEqual(self.MIPS.s4, 6, "Didn't convert 6.66 to word")
