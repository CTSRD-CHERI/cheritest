#-
# Copyright (c) 2011 Steven J. Murdoch
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

import sys
import xml.dom.minidom as minidom
import xml.etree.ElementTree as ET
import argparse

###
### Process the XML output of nose to show failing/error test cases
###

if sys.version < '2.7':
   print 'Python 2.7 or later needed for ".." notation in ElementTree findall()'
   sys.exit()

def prettyPrint(element):
  txt = ET.tostring(element)
  return minidom.parseString(txt).toprettyxml()

def prettyPrintItems(etree, tag, prefix, verbose):
  failure_count=0
  ## Find the parent tag of all matching tags 
  for e in etree.findall('.//%s/..'%tag):
    failure_count+=1
    if verbose:
      print prefix + prettyPrint(e)
    else:
      print prefix + e.attrib["name"]
  return failure_count 

def main():
  parser = argparse.ArgumentParser(description='Process the XML output of nose to show failing/error test cases.')
  parser.add_argument('fh', type=file, help='XML file (in xUnit format) to parse', metavar='FILE', nargs='+')
  parser.add_argument('--verbose', '-v', dest='verbose', action='store_true', help='Show full error/failure details')
  args = parser.parse_args() 
 
  failure_count = 0
  for fh in args.fh:
    etree = ET.parse(fh)
    failure_count += prettyPrintItems(etree, 'failure', fh.name+' F: ', args.verbose)
    failure_count += prettyPrintItems(etree, 'error', fh.name+' E: ', args.verbose)

  print "Failures: %d"%failure_count
  if failure_count:
    sys.exit(1)
  
if __name__=="__main__":
  main()
