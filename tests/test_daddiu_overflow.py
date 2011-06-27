from bsim_utils import BaseBsimTestCase

class test_daddiu_overflow(BaseBsimTestCase):
    def test_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "daddiu triggered overflow exception")
