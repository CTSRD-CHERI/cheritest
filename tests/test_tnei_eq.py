from bsim_utils import BaseBsimTestCase

class test_tnei_eq(BaseBsimTestCase):
    def test_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "tnei trapped when equal")
