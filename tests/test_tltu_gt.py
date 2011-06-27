from bsim_utils import BaseBsimTestCase

class test_tltu_gt(BaseBsimTestCase):
    def test_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "tltu trapped when greater than")

