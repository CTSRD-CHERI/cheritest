#!/bin/sh

command -v mlton >/dev/null 2>&1 || \
  { echo >&2 "Please type 'sudo apt-get install mlton', then retry."; exit 1; }

if [ -d l3mips ]; then
  echo "Directory l3mips already present"
  echo "Remove l3mips directory if you wish to reinstall"
  exit
fi

git clone https://github.com/acjf3/l3mips
cd l3mips
wget http://downloads.sourceforge.net/project/polyml/polyml/5.5.2/polyml.5.5.2.tar.gz
tar -xf polyml.5.5.2.tar.gz
cd polyml.5.5.2/
./configure
make
export PATH=`pwd`:$PATH
cd ..
wget http://www.cl.cam.ac.uk/~acjf3/l3/l3.tar.bz2
mkdir L3
tar xf l3.tar.bz2 -C L3 --strip-components 1
cd L3
cat Makefile | sed 's/-Wl,-no_pie//g' > NewMakefile
mv NewMakefile Makefile
make
cd ..
cp L3/bin/* .
make CAP=256
make clean
make CAP=c128
make clean
echo
echo "==========================================================="
echo "Done"
echo "For fuzz testing against 256-bit capabilities, please type:"
echo "  export L3CHERI=l3mips/l3mips-cheri256"
echo ""
echo "For fuzz testing against 128-bit capabilities, please type:"
echo "  export L3CHERI=l3mips/l3mips-cheric128"
echo "==========================================================="
