from bsim_utils import BaseBsimTestCase

class test_tlt_eq(BaseBsimTestCase):
    def test_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "tlt trapped when equal to")

