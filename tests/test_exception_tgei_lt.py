from bsim_utils import BaseBsimTestCase

class test_exception_tgei_lt(BaseBsimTestCase):
    def test_tgei_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "tgei trapped when less than")
