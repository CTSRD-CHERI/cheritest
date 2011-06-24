from bsim_utils import BaseBsimTestCase

class test_exception_tge_lt(BaseBsimTestCase):
    def test_tge_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "tge trapped when less than")
