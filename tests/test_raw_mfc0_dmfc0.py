from bsim_utils import BaseBsimTestCase

class raw_mfc0_dmfc0(BaseBsimTestCase):
    def test_dmfc0_correct(self):
        '''Check that the value from the EPC is the label'''
        self.assertRegisterEqual(self.MIPS.a0, self.MIPS.a2, "Read from EPC, with dmfc0, was not the same as desired label")

    def test_mfc0_correct(self):
        self.assertRegisterEqual((self.MIPS.a0 << 32) % 0x10000000000000000, (self.MIPS.a1 << 32) % 0x10000000000000000, "Read from EPC, with mfc0, was not the 32 least significant bits of the desired label")

    def test_eret_to_label(self):
        self.assertRegisterNotEqual(self.MIPS.a3, 1, "Instruction before label executed, eret unsuccessful")
        self.assertRegisterEqual(self.MIPS.a4, 2, "Instruction at label not executed, eret unsuccessful")
