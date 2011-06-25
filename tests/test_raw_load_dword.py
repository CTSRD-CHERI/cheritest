from bsim_utils import BaseBsimTestCase

class raw_load_dword(BaseBsimTestCase):
    def test_a0(self):
        '''Test load double word instruction'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210)

    def test_a1(self):
        '''Test load positive double word'''
        self.assertRegisterEqual(self.MIPS.a1, 0x7fffffffffffffff)

    def test_a2(self):
        '''Test load negative double word'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff)
