#!/bin/bash

make
CC="$(pwd)/ssc_compiler"

cd tests
for test_file in $(find . -name "*.ssc"); do
    echo "Running test: $test_file"
    $CC $test_file
    echo ""
done