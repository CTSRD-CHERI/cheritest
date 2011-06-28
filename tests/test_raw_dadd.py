from bsim_utils import BaseBsimTestCase

class raw_dadd(BaseBsimTestCase):
    def test_independent_inputs(self):
        '''Check that simple dadd worked, no input modification'''
        self.assertRegisterEqual(self.MIPS.s3, 1, "dadd modified first input")
        self.assertRegisterEqual(self.MIPS.s4, 2, "dadd modified second input")
        self.assertRegisterEqual(self.MIPS.a0, 3, "dadd failed")

    def test_into_first_input(self):
        self.assertRegisterEqual(self.MIPS.a1, 3, "dadd into first input failed")

    def test_into_second_input(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "dadd into second input failed")

    def test_into_both_input(self):
        self.assertRegisterEqual(self.MIPS.a3, 2, "dadd into both inputs failed")

    def test_pipeline(self):
        self.assertRegisterEqual(self.MIPS.a4, 6, "dadd-to-dadd pipeline failed")

    def test_pos_neg_to_zero(self):
        self.assertRegisterEqual(self.MIPS.a5, 0, "positive plus negative to zero failed")

    def test_neg_neg_to_neg(self):
        self.assertRegisterEqual(self.MIPS.a6, 0xfffffffffffffffe, "negative plus negative to negative failed")

    def test_neg_pos_to_pos(self):
        self.assertRegisterEqual(self.MIPS.a7, 1, "negative plus positive to positive failed")

    def test_neg_pos_to_neg(self):
        self.assertRegisterEqual(self.MIPS.s0, 0xffffffffffffffff, "positive plus negative to negative failed")
