from bsim_utils import BaseBsimTestCase

class test_addu_overflow(BaseBsimTestCase):
    def test_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "addu triggered overflow exception")
