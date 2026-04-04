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
    modules=$(ls tb)
fi

log='verilatorTestLog'
if [[ -f ${log} ]] ; then rm ${log} ; fi
totalTests=0
passedTests=0
failedTests=0

echo '=========='
for module in ${modules} ; do
    echo "testing ${module}"
    if ! [[ -d tb/${module} ]] ; then
        echo "no test directory for ${module}" 1>&2
        exit 1
    fi
    echo 'building'
    if [[ -f obj/tb.o ]] ; then rm obj/tb.o ; fi
    if [[ -f obj/tb.d ]] ; then rm obj/tb.d ; fi
    if ! verilator -sv --cc --Wall --Wpedantic --Wno-UNUSED --Mdir obj -CFLAGS '-I../util' -f tb/${module}/files.f --top-module ${module} --exe --build tb/${module}/tb.cpp >>${log} ; then
        echo "verilator failed to compile testbench for ${module}" 1>&2
        exit 1
    fi
    echo 'testing'
    if ./obj/V${module} ; then
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
