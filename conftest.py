import os
import pytest
import shlex
import sys
import typing
from enum import Enum
from pathlib import Path


def tristate_bool_from_str(value: str):
    if value is None:
        return None
    if value.lower() not in ("0", "false", "no"):
        return True
    return False


def infer_logdir(config):
    if not config.option.TEST_MACHINE:
        return None
    return str(config.rootdir)


class CheritestOptions(Enum):
    TEST_MACHINE = ("--cheri-test-machine", {})
    LOGDIR = ("--cheri-logdir", {})
    CAP_SIZE = ("--cheri-cap-size", {"choices": [64, 128, 256], "type": int})
    PERM_SIZE = ("--cheri-perm-size", {"type": int})

    def __init__(self, cmdline_flag, argparse_args):
        self.cmdline_flag = cmdline_flag
        self.argparse_args = argparse_args
        if "default" not in self.argparse_args:
            self.argparse_args["default"] = os.getenv(self.name)
        self.argparse_args["help"] = "Alternative to env var $" + self.name + " (default value: " + str(self.argparse_args["default"]) + ")"


def pytest_addoption(parser):
    # TODO: this should probably be pytest_sessionstart?
    # ensure the root directoy is in PYTHONPATH
    cheritest_root = Path(__file__).parent
    if str(cheritest_root) not in sys.path:
        sys.path.insert(0, str(cheritest_root))
    if str(cheritest_root / "tools/sim") not in sys.path:
        sys.path.append(str(cheritest_root / "tools/sim"))

    # TODO: add a command line option to skip features
    parser.addoption("--unsupported-features", action="append", default=[])
    parser.addoption("--unsupported-feature-if-equal", action="append", default=[])
    for option in CheritestOptions:
        parser.addoption(option.cmdline_flag, dest=option.name, **option.argparse_args)


def pytest_configure(config):
    #import _pytest.config
    #assert isinstance(config, _pytest.config.Config)
    # TODO: add the available features to the config object
    #  if LOGDIR/CAP_SIZE/CHERI_C0_IS_NULL/TEST_MACHINE are not set, set sensible default values (QEMU)
    print(config.getoption(CheritestOptions.TEST_MACHINE.name))
    if config.option.help:
        return

    config.CHERITEST_UNSUPPORTED_FEATURES = dict()  # type: typing.Dict[str, typing.List[str]]
    for i in config.getoption("unsupported_features"):
        for feature in shlex.split(i):
            if not config.CHERITEST_UNSUPPORTED_FEATURES.get(feature):
                config.CHERITEST_UNSUPPORTED_FEATURES[feature] = ["ALWAYS"]
    for i in config.getoption("unsupported_feature_if_equal"):
        for pair in shlex.split(i):
            key, value = pair.split("=", maxsplit=1)
            if not config.CHERITEST_UNSUPPORTED_FEATURES.get(key):
                config.CHERITEST_UNSUPPORTED_FEATURES[key] = list()
            config.CHERITEST_UNSUPPORTED_FEATURES[key].append(value)

    # Infer values based on CAP_SIZE
    # if config.option.
    for option in CheritestOptions:
        value = config.getoption(option.name)
        # TODO: infer default values
        if not value:
            raise pytest.UsageError("env var $" + option.name + " or option " + option.cmdline_flag + " must be set!")
