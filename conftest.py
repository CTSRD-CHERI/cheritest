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
    CAP_SIZE = ("--cheri-cap-size", {"choices": [0, 64, 128, 256], "type": int})
    PERM_SIZE = ("--cheri-perm-size", {"type": int})

    def __init__(self, cmdline_flag, argparse_args):
        self.cmdline_flag = cmdline_flag
        self.argparse_args = argparse_args
        if "default" not in self.argparse_args:
            self.argparse_args["default"] = os.getenv(self.name)
        self.argparse_args["help"] = "Alternative to env var $" + self.name + " (default value: " + str(self.argparse_args["default"]) + ")"


config_options_from_pytest = None
config_object = None


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
    #  if LOGDIR/CAP_SIZE/TEST_MACHINE are not set, set sensible default values (QEMU)
    print("TEST_MACHINE:", config.getoption(CheritestOptions.TEST_MACHINE.name))
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
        if value is None and option == CheritestOptions.PERM_SIZE:
            cap_size = config.getoption(CheritestOptions.CAP_SIZE.name)
            if cap_size == 256:
                value = 31
            elif cap_size == 128:
                value = 15
        if value is None:
            raise pytest.UsageError("env var $" + option.name + " or option " + option.cmdline_flag + " must be set!")

    global config_options_from_pytest
    global config_object
    config_options_from_pytest = config.option
    config_object = config


def pytest_ignore_collect(path, config):
    path_str = str(path)
    if "/tests/" not in path_str:
        # print("Ignoring dir", path, "since it is not below tests/ directory.")
        return True
    if "/__pycache__" in path_str:
        # print("Ignoring dir", path, "since it is python bitcode.")
        return True
    skip_paths = {
        "fuzz_test": "/tests/fuzz",
        "fuzz_test_regression": "/tests/fuzz_regressions",
        "multicore": "/tests/multicore",
        "float": "/tests/fpu",
        "trace_tests": "/tests/trace",
        "beri_statcounters": "/tests/statcounters",
        "cache": "/tests/cache",
        "capabilities": "/tests/cp2",
    }
    check_path = path_str
    if os.path.isfile(path_str):
        check_path = os.path.dirname(path_str)

    for opt, skip_path in skip_paths.items():
        if check_path.endswith(skip_path) and config.CHERITEST_UNSUPPORTED_FEATURES.get(opt):
            if os.path.isdir(path_str):
                print("Ignoring test dir", skip_path, "since attr", opt, "is unsupported.")
            else:
                print("Ignoring test file", os.path.basename(path_str), "since attr", opt, "is unsupported.")
            return True
    return False

# https://docs.pytest.org/en/latest/assert.html#defining-your-own-assertion-comparison
# print integer comparison failures as hex:
# This can be uncommented to force all integer comparisons to be printed as hex
# Note: the where clauses will then no longer be printed
#def pytest_assertrepr_compare(config, op, left, right):
#    if isinstance(left, int) and isinstance(right, int):
#        return ['0x%x %s 0x%x' % (left, op, right)]
