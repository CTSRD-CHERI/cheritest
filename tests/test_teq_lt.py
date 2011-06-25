from bsim_utils import BaseBsimTestCase

class test_teq_lt(BaseBsimTestCase):
    def test_teq_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "teq trapped when less than")
