#!/usr/bin/env python

import re
import os
from os import path
import sys
import subprocess

def main():
    tests = sorted([fn for fn in os.listdir('x86-obj')
                    if re.match(r'^dmamodel_[^\.]+$', fn) is not None])
    test_files = [path.abspath(path.join('x86-obj', fn)) for fn in tests]
    test_names = [fn.split('_', 1)[1] for fn in tests]
    for name, fn in zip(test_names, test_files):
        sys.stdout.write('{0}. '.format(name))
        try:
            subprocess.check_output([fn])
        except subprocess.CalledProcessError as ex:
            print 'FAILED! (assert on line {0})'.format(ex.output.strip())
            continue
        print 'Passed.'

if __name__=='__main__':
    main()
