from bsim_utils import BaseBsimTestCase

class test_tlti_gt_sign(BaseBsimTestCase):
    def test_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "tlti trapped when greater than (negative)")

