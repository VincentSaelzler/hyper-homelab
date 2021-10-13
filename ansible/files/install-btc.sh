#!/bin/bash

# get the latest final release version and check it out
version=`git tag -n | sort -V | grep final | tail -n 1 | sed 's/ .*//'`
echo $version
git checkout $version

# # install Berkeley DB v4.8
# ./contrib/install_db4.sh `pwd`