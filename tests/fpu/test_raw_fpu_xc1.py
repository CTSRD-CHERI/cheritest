from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_xc1(BaseCHERITestCase):
    def test_words(self):
        '''Test we can store words at indexed location offsets.'''
        self.assertRegisterEqual(self.MIPS.s0, 0xFFFFFFFFABCD0000, 'Failed to save and load offset 0')
        self.assertRegisterEqual(self.MIPS.s1, 0x43210000, 'Failed to save and load offset 4')

    def test_doubles(self):
        '''Test we can store doubles at indexed location offsets.'''
        self.assertRegisterEqual(self.MIPS.s2, 0xFEED000000000000, 'Failed to save and load offset 0.')
        self.assertRegisterEqual(self.MIPS.s3, 0xFFFFFACE00000000, 'Failed to save and load offset 8.')
