from bsim_utils import BaseBsimTestCase

class test_template(BaseBsimTestCase):
    def test_template(self):
        ## Check equality
        self.assertRegisterEqual(0, 0, "Failure description here")
        ## Check inequality
        self.assertRegisterNotEqual(0, 1, "Failure description here")
        ## Access register by name
        self.MIPS.zero
        ## Access register by number
        self.MIPS[0]
