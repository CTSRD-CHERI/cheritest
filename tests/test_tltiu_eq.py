from bsim_utils import BaseBsimTestCase

class test_tltiu_eq(BaseBsimTestCase):
    def test_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "tltiu trapped when equal to")

