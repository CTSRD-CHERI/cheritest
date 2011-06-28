from bsim_utils import BaseBsimTestCase

class raw_daddiu(BaseBsimTestCase):
    def test_independent_inputs(self):
        '''Check that simple add worked, no input modification'''
        self.assertRegisterEqual(self.MIPS.a0, 1, "daddiu modified input")
        self.assertRegisterEqual(self.MIPS.a1, 2, "daddiu failed")

    def test_into_input(self):
        self.assertRegisterEqual(self.MIPS.a2, 2, "daddiu into input failed")

    def test_pipeline(self):
        self.assertRegisterEqual(self.MIPS.a3, 3, "daddiu-to-daddiu pipeline failed")

    def test_sign_extended_immediate(self):
        self.assertRegisterEqual(self.MIPS.a4, 0, "daddiu immediate not signed")
