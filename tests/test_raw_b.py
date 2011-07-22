from bsim_utils import BaseBsimTestCase

class raw_b(BaseBsimTestCase):
    def test_t0(self):
        self.assertRegisterNotEqual(self.MIPS.t0, 0, "instruction before branch missed")

    def test_t1(self):
        self.assertRegisterNotEqual(self.MIPS.t1, 0, "instruction in branch-delay slot missed")

    def test_t2(self):
        self.assertRegisterEqual(self.MIPS.t2, 0, "branch failed to skip instruction")

    def test_t3(self):
        self.assertRegisterNotEqual(self.MIPS.t3, 0, "branch target missed")
