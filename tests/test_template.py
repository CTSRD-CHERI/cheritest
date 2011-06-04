from bsim_utils import BaseBsimTestCase

class test_template(BaseBsimTestCase):
    def test_template(self):
        ## Check equality
        self.assertRegisterEqual(0, 0)
        ## Check inequality
        self.assertRegisterNotEqual(0, 1)
        ## Access register by name
        self.MIPS.zero
        ## Access register by number
        self.MIPS[0]
