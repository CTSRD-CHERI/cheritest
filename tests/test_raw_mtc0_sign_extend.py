from bsim_utils import BaseBsimTestCase

class raw_mtc0_sign_extend(BaseBsimTestCase):
    def test_mtc0_signext(self):
        '''MTC0 should sign extend (some documentation suggests all 64-bits should be copied but sign-extension is logical and in line with other operations and GXemul)'''
        self.assertRegisterEqual(self.MIPS.a0, 0x00000000ffff0000, "LUI instruction failed")
        self.assertRegisterEqual(self.MIPS.a0|0xffffffff00000000, self.MIPS.a2, "Value not copied in and out of EPC correctly")

    def test_mfc0_signext_mtc0(self):
        self.assertRegisterEqual(self.MIPS.a0|0xffffffff00000000, self.MIPS.a1, "MFC0 did not correctly sign extend")

    def test_dmtc0_nosignext(self):
        self.assertRegisterEqual(self.MIPS.a0, self.MIPS.a4, "Value was altered in process of dmtc0 and dmfc0")

    def test_mfc0_signext_dmtc0(self):
        self.assertRegisterEqual(self.MIPS.a0|0xffffffff00000000, self.MIPS.a3, "MFC0 did not correctly sign extend")


