from bsim_utils import BaseBsimTestCase

class test_tltiu_gt_sign(BaseBsimTestCase):
    def test_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "tltiu trapped when greater than (but less than if signed)")
