from bsim_utils import BaseBsimTestCase

class raw_subu(BaseBsimTestCase):
    def test_independent_inputs(self):
        '''Check that simple subu worked, no input modification'''
        self.assertRegisterEqual(self.MIPS.s3, 2, "subu modified first input")
        self.assertRegisterEqual(self.MIPS.s4, 1, "subu modified second input")
        self.assertRegisterEqual(self.MIPS.a0, 1, "subu failed")

    def test_into_first_input(self):
        self.assertRegisterEqual(self.MIPS.a1, 1, "subu into first input failed")

    def test_into_second_input(self):
        self.assertRegisterEqual(self.MIPS.a2, 1, "subu into second input failed")

    def test_into_both_input(self):
        self.assertRegisterEqual(self.MIPS.a3, 0, "subu into both inputs failed")

    def test_pipeline(self):
        self.assertRegisterEqual(self.MIPS.a4, 1, "subu-to-subu pipeline failed")

    def test_pos_neg_to_zero(self):
        self.assertRegisterEqual(self.MIPS.a5, 0, "positive minus positive to zero failed")

    def test_neg_neg_to_neg(self):
        self.assertRegisterEqual(self.MIPS.a6, 0xfffffffffffffffe, "negative minus positive to 64-bit sign-extended negative failed")

    def test_neg_pos_to_pos(self):
        self.assertRegisterEqual(self.MIPS.a7, 1, "negative minus negative to positive failed")

    def test_neg_pos_to_neg(self):
        self.assertRegisterEqual(self.MIPS.s0, 0xffffffffffffffff, "positive minus positive to 64-bit sign-extended negative failed")

    def test_pos_sign_extend(self):
        self.assertRegisterEqual(self.MIPS.s1, 1, "positive 64-bit sign extend failed")

    def test_neg_sign_extend(self):
        self.assertRegisterEqual(self.MIPS.s2, 0xfffffffffffffffe, "negative 64-bit sign extend failed")
