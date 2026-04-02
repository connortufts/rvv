#!/bin/bash

# simple wrapper script for linting individual files
# to use:
# $ ./lint.sh module1.sv module2.sv
#   takes each sv file specified on command line and runs it through the linter

for modulefile in $@ ; do
    verilator -sv --lint-only --Wall --Wpedantic ${modulefile}
done
