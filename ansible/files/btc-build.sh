#!/bin/bash
# based on https://jonatack.github.io/articles/how-to-compile-bitcoin-core-and-run-the-tests

# get the latest final release version and check it out
version=`git tag -n | sort -V | grep final | tail -n 1 | sed 's/ .*//'`
git checkout $version

# compile Berkeley DB v4.8
./contrib/install_db4.sh `pwd`

# configure bitcoin to use the compiled version of Berkely DB 
export BDB_PREFIX="/home/$1/bitcoin/db4"
./autogen.sh
./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include"

# build bitcoin
# seemed to work - took like 30 minus + with single CPU
make -j "$(($(nproc)+1))"

# will need to figure out how to parse output of tests
# make -j "$(($(nproc)+1))" check

# will need to parse output and also determine whether having failures is an issue
# python3 ./test/functional/test_runner.py -j 64
