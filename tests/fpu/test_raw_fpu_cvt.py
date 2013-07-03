from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_cvt(BaseCHERITestCase):
    def test_convert_word_to_single(self):
        '''Test we can convert words to single floating point'''
        self.assertRegisterEqual(self.MIPS.t0, 0x3F800000, "Didn't convert 1 to FP")
        self.assertRegisterEqual(self.MIPS.t1, 0x4C00041A, "Didn't convert non exact to FP")
        self.assertRegisterEqual(self.MIPS.t2, 0xFFFFFFFFC1B80000, "Didn't convert -23 to FP")

    def test_convert_double_to_single(self):
        '''Test we can convert doubles to singles'''
        self.assertRegisterEqual(self.MIPS.s0, 0x3F800000, "Didn't convert 1 from double.")
        self.assertRegisterEqual(self.MIPS.s1, 0x3e2aaaaa, "Didn't convert 1/6 from double.")
        self.assertRegisterEqual(self.MIPS.s2, 0xffffffffc36aa188, "Didn't convert -234.6311 from double")
        self.assertRegisterEqual(self.MIPS.s3, 0x4f0c0473, "Didn't convert large number from double.")

    def test_convert_singles_to_doubles(self):
        '''Test we can convert singles to doubles'''
        self.assertRegisterEqual(self.MIPS.s4, 0x3FF0000000000000, "Didn't convert 1 to double.")
        self.assertRegisterEqual(self.MIPS.s5, 0x3FC99999A0000000, "Didn't conver 0.2 to double.")
        self.assertRegisterEqual(self.MIPS.s6, 0xC0D1DCE8C0000000, "Didn't convert -18291.636 to double")

    def test_convert_ps_to_s(self):
        '''Test we can convert paired single to single'''
        self.assertRegisterEqual(self.MIPS.a0, 0x33333333, "Didn't extract lower single.")
        self.assertRegisterEqual(self.MIPS.a1, 0xDDDDDDDD, "Didn't extract upper single.")
