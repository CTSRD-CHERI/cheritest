from bsim_utils import BaseBsimTestCase

class raw_store_byte(BaseBsimTestCase):
    def test_a0(self):
        '''Test unsigned load of stored byte from double word'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfe)

    def test_a1(self):
        '''Test signed load of stored positive byte'''
        self.assertRegisterEqual(self.MIPS.a1, 1)

    def test_a2(self):
        '''Test signed load of stored negative byte'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff)

    def test_a3(self):
        '''Test unsigned load of stored positive byte'''
        self.assertRegisterEqual(self.MIPS.a3, 1)

    def test_a4(self):
        '''Test unsigned load of stored negative byte'''
        self.assertRegisterEqual(self.MIPS.a4, 0xff)
