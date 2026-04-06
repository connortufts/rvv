#!/bin/bash

# to use:
# $ ./test.sh
#   locates all testable modules by listing through each subdirectory in tb/
#   then builds and tests each module individually with tb/[name]/tb.cpp as the testbench and all module source located by entries in tb/[name]/files.f
#
# $ ./test.sh module1 module2 ...
#   does the same function as the above command form but you specify module names manually on command line with module1 module2 and so on
#   useful if you just want to test one or two indiviudal modules instead of doing a complete test

if [[ $# -gt 0 ]] ; then
    modules=$@
else
    modules=$(find tb/* -maxdepth 0 -type d)
fi

log='verilatorTestLog'
if [[ -f ${log} ]] ; then rm ${log} ; fi
totalTests=0
passedTests=0
failedTests=0

echo '=========='
for module in ${modules} ; do
    name=$(basename ${module})
    echo "testing ${name}"
    if ! [[ -d tb/${name} ]] ; then
        echo "no test directory for ${name}" 1>&2
        exit 1
    fi
    echo 'building'
    if [[ -f obj/tb.o ]] ; then rm obj/tb.o ; fi
    if [[ -f obj/tb.d ]] ; then rm obj/tb.d ; fi
    if ! verilator -sv --cc --Wall --Wpedantic --Wno-UNUSED --Mdir obj -CFLAGS '-I../util' -f tb/default.f -f tb/${name}/files.f --top-module ${name} --exe --build tb/${name}/tb.cpp >>${log} ; then
        echo "verilator failed to compile testbench for ${name}" 1>&2
        exit 1
    fi
    echo 'testing'
    if ./obj/V${name} ; then
        passedTests=$((passedTests + 1))
        echo 'PASSED'
    else
        failedTests=$((failedTests + 1))
        echo '>>> FAILED <<<'
    fi
    totalTests=$((totalTests + 1))
    echo '=========='
done

echo ''
echo "passed ${passedTests}/${totalTests} tests"
echo "failed ${failedTests}/${totalTests} tests"
