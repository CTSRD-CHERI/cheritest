from bsim_utils import BaseBsimTestCase

class test_tgeu_lt(BaseBsimTestCase):
    def test_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "tgeu trapped when less than")
