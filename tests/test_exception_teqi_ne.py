from bsim_utils import BaseBsimTestCase

class test_exception_teqi_ne(BaseBsimTestCase):
    def test_teqi_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "teqi trapped when not equal")
