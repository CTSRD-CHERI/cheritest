from bsim_utils import BaseBsimTestCase

class test_subu_overflow(BaseBsimTestCase):
    def test_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "subu triggered overflow exception")
