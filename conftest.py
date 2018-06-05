import sys
from pathlib import Path

def pytest_addoption(parser):
    # TODO: this should probably be pytest_sessionstart?
    # ensure the root directoy is in PYTHONPATH
    cheritest_root = Path(__file__).parent
    if str(cheritest_root) not in sys.path:
        sys.path.insert(0, str(cheritest_root))
    if str(cheritest_root / "tools/sim") not in sys.path:
        sys.path.append(str(cheritest_root / "tools/sim"))

    # TODO: add a command line option to skip features


def pytest_configure(config):
    # TODO: add the available features to the config object
    import pprint
    pprint.pprint(vars(config))



