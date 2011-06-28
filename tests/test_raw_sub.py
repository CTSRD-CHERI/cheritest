from bsim_utils import BaseBsimTestCase

class raw_sub(BaseBsimTestCase):
    def test_independent_inputs(self):
        '''Check that simple sub worked, no input modification'''
        self.assertRegisterEqual(self.MIPS.s3, 2, "sub modified first input")
        self.assertRegisterEqual(self.MIPS.s4, 1, "sub modified second input")
        self.assertRegisterEqual(self.MIPS.a0, 1, "sub failed")

    def test_into_first_input(self):
        self.assertRegisterEqual(self.MIPS.a1, 1, "sub into first input failed")

    def test_into_second_input(self):
        self.assertRegisterEqual(self.MIPS.a2, 1, "sub into second input failed")

    def test_into_both_input(self):
        self.assertRegisterEqual(self.MIPS.a3, 0, "sub into both inputs failed")

    def test_pipeline(self):
        self.assertRegisterEqual(self.MIPS.a4, 1, "sub-to-sub pipeline failed")

    def test_pos_neg_to_zero(self):
        self.assertRegisterEqual(self.MIPS.a5, 0, "positive minus negative to zero failed")

    def test_neg_neg_to_neg(self):
        self.assertRegisterEqual(self.MIPS.a6, 0xfffffffffffffffe, "negative minus negative to negative failed")

    def test_neg_pos_to_pos(self):
        self.assertRegisterEqual(self.MIPS.a7, 1, "negative minus positive to positive failed")

    def test_neg_pos_to_neg(self):
        self.assertRegisterEqual(self.MIPS.s0, 0xffffffffffffffff, "positive minus negative to negative failed")

    def test_pos_sign_extend(self):
        self.assertRegisterEqual(self.MIPS.s1, 1, "positive 64-bit sign extend failed")

    def test_neg_sign_extend(self):
        self.assertRegisterEqual(self.MIPS.s2, 0xfffffffffffffffe, "negative 64-bit sign extend failed")
