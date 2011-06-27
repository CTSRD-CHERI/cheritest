from bsim_utils import BaseBsimTestCase

class test_tne_eq(BaseBsimTestCase):
    def test_tne_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "tne trapped when equal")
