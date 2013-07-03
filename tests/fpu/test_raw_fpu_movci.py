from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_movci(BaseCHERITestCase):
    def test_movf(self):
        '''Test movf instruction works'''
        self.assertRegisterEqual(self.MIPS.s1, 0xDEAD, 'MOVF failed to move')
        self.assertRegisterEqual(self.MIPS.s3, 0x1111, 'MOVF moved badly')

    def test_movt(self):
        '''Test movt instruction works'''
        self.assertRegisterEqual(self.MIPS.s2, 0x1111, 'MOVT moved badly')
        self.assertRegisterEqual(self.MIPS.s4, 0xDEAD, 'MOVT failed to move')
