from bsim_utils import BaseBsimTestCase

class raw_dsubu(BaseBsimTestCase):
    def test_independent_inputs(self):
        '''Check that simple dsubu worked, no input modification'''
        self.assertRegisterEqual(self.MIPS.s3, 2, "dsubu modified first input")
        self.assertRegisterEqual(self.MIPS.s4, 1, "dsubu modified second input")
        self.assertRegisterEqual(self.MIPS.a0, 1, "dsubu failed")

    def test_into_first_input(self):
        self.assertRegisterEqual(self.MIPS.a1, 1, "dsubu into first input failed")

    def test_into_second_input(self):
        self.assertRegisterEqual(self.MIPS.a2, 1, "dsubu into second input failed")

    def test_into_both_input(self):
        self.assertRegisterEqual(self.MIPS.a3, 0, "dsubu into both inputs failed")

    def test_pipeline(self):
        self.assertRegisterEqual(self.MIPS.a4, 1, "dsubu-to-dsubu pipeline failed")
