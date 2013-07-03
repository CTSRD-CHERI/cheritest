from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_sd_ld(BaseCHERITestCase):
    def test_preloaded(self):
        '''Test can load double from memory'''
        self.assertRegisterEqual(self.MIPS.s0, 0x0123456789abcdef, 'Failed to load preloaded double.')

    def test_offset(self):
        '''Test we can store doubles at location offsets.'''
        self.assertRegisterEqual(self.MIPS.s1, 0xBED0000000000000, 'Failed to save and load offset 0.')
        self.assertRegisterEqual(self.MIPS.s2, 0x1212000000000000, 'Failed to save and load offset 4.')
