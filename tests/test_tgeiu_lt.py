from bsim_utils import BaseBsimTestCase

class test_tgeiu_lt(BaseBsimTestCase):
    def test_tgeiu_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "tgeiu trapped when less than")
