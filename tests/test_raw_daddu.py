from bsim_utils import BaseBsimTestCase

class raw_daddu(BaseBsimTestCase):
    def test_independent_inputs(self):
        '''Check that simple daddu worked, no input modification'''
        self.assertRegisterEqual(self.MIPS.s3, 1, "daddu modified first input")
        self.assertRegisterEqual(self.MIPS.s4, 2, "daddu modified second input")
        self.assertRegisterEqual(self.MIPS.a0, 3, "daddu failed")

    def test_into_first_input(self):
        self.assertRegisterEqual(self.MIPS.a1, 3, "daddu into first input failed")

    def test_into_second_input(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "daddu into second input failed")

    def test_into_both_input(self):
        self.assertRegisterEqual(self.MIPS.a3, 2, "daddu into both inputs failed")

    def test_pipeline(self):
        self.assertRegisterEqual(self.MIPS.a4, 6, "daddu-to-daddu pipeline failed")
