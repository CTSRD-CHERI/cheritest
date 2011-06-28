from bsim_utils import BaseBsimTestCase

class raw_daddi(BaseBsimTestCase):
    def test_independent_inputs(self):
        '''Check that simple add worked, no input modification'''
        self.assertRegisterEqual(self.MIPS.a0, 1, "daddi modified input")
        self.assertRegisterEqual(self.MIPS.a1, 2, "daddi failed")

    def test_into_input(self):
        self.assertRegisterEqual(self.MIPS.a2, 2, "daddi into input failed")

    def test_pipeline(self):
        self.assertRegisterEqual(self.MIPS.a3, 3, "daddi-to-daddi pipeline failed")

    def test_sign_extended_immediate(self):
        self.assertRegisterEqual(self.MIPS.a4, 0, "daddi immediate not signed")

    def test_pos_neg_to_zero(self):
        self.assertRegisterEqual(self.MIPS.a5, 0, "positive plus negative to zero failed")

    def test_neg_neg_to_neg(self):
        self.assertRegisterEqual(self.MIPS.a6, 0xfffffffffffffffe, "negative plus negative to negative failed")

    def test_neg_pos_to_pos(self):
        self.assertRegisterEqual(self.MIPS.a7, 1, "negative plus positive to positive failed")

    def test_neg_pos_to_neg(self):
        self.assertRegisterEqual(self.MIPS.s0, 0xffffffffffffffff, "positive plus negative to negative failed")
