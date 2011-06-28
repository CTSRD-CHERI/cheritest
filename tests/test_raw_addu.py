from bsim_utils import BaseBsimTestCase

class raw_addu(BaseBsimTestCase):
    def test_independent_inputs(self):
        '''Check that simple addu worked, no input modification'''
        self.assertRegisterEqual(self.MIPS.s3, 1, "addu modified first input")
        self.assertRegisterEqual(self.MIPS.s4, 2, "addu modified second input")
        self.assertRegisterEqual(self.MIPS.a0, 3, "addu failed")

    def test_into_first_input(self):
        self.assertRegisterEqual(self.MIPS.a1, 3, "addu into first input failed")

    def test_into_second_input(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "addu into second input failed")

    def test_into_both_input(self):
        self.assertRegisterEqual(self.MIPS.a3, 2, "addu into both inputs failed")

    def test_pipeline(self):
        self.assertRegisterEqual(self.MIPS.a4, 6, "addu-to-addu pipeline failed")

    def test_pos_neg_to_zero(self):
        self.assertRegisterEqual(self.MIPS.a5, 0, "positive plus negative to zero failed")

    def test_neg_neg_to_neg(self):
        self.assertRegisterEqual(self.MIPS.a6, 0xfffffffffffffffe, "negative plus negative to 64-bit sign-extended negative failed")

    def test_neg_pos_to_pos(self):
        self.assertRegisterEqual(self.MIPS.a7, 1, "negative plus positive to positive failed")

    def test_neg_pos_to_neg(self):
        self.assertRegisterEqual(self.MIPS.s0, 0xffffffffffffffff, "positive plus negative to 64-bit sign-extended negative failed")

    def test_pos_sign_extend(self):
        self.assertRegisterEqual(self.MIPS.s1, 1, "positive 64-bit sign extend failed")

    def test_neg_sign_extend(self):
        self.assertRegisterEqual(self.MIPS.s2, 0xffffffffffffffff, "negative 64-bit sign extend failed")
