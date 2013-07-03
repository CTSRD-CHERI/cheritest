from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_sw_lw(BaseCHERITestCase):
    def test_positive(self):
        '''Test can save and load positive float'''
        self.assertRegisterEqual(self.MIPS.s0, 0x3F800000, 'Failed to save and load 1.')

    def test_negative(self):
        '''Test can save and load negative float'''
        self.assertRegisterEqual(self.MIPS.s1, 0xFFFFFFFFBF800000, 'Failed to save and load -1.')

    def test_offset(self):
        '''Test we can store floats at location offsets.'''
        self.assertRegisterEqual(self.MIPS.s2, 0x41800000, 'Failed to save and load offset 0.')
        self.assertRegisterEqual(self.MIPS.s3, 0x3D800000, 'Failed to save and load offset 4.')
