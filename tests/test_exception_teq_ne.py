from bsim_utils import BaseBsimTestCase

class test_exception_teq_ne(BaseBsimTestCase):
    def test_teq_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "teq trapped when not equal")
