#-----------------------------------------------------------------------------
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from ARM Limited or its affiliates.
#
#            (C) COPYRIGHT 2010-2013 ARM Limited or its affiliates.
#                ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from ARM Limited or its affiliates.
#
#  Version and Release Control Information:
#
#  File Revision       : $Revision: 368444 $
#  File Date           : $Date: 2017-07-25 15:10:13 +0100 (Tue, 25 Jul 2017) $
#
#  Release Information : ARM Internal
#-----------------------------------------------------------------------------
#
# Cortex-M0 DesignStart RTL Bundle simulation make file
#
#-----------------------------------------------------------------------------

MODULE          = . /usr/share/Modules/init/sh; module load licenses/synopsys licenses/mentor-graphics licenses/cadence
VCS_MODULE      = tools/vcs/T-2022.06-SP2-9
VERDI_MODULE    = tools/verdi/T-2022.06-1 
VERDI_HOME      = /usr/cots/synopsys/verdi/T-2022.06-1

#  Configurations
#
# Name of test directory (e.g. hello, dhry)
# TESTNAME must be specified on the make command line
TESTNAME    = lab5_a

# List of all tests (this is used when running 'make all/clean')
TEST_LIST   = hello 

#dhry sleep_demo interrupt_demo dualtimer_demo \
 self_reset_demo watchdog_demo rtx_demo gpio_tests timer_tests \
 uart_tests default_slaves_tests gpio_driver_tests uart_driver_tests \
 timer_driver_tests apb_mux_tests memory_tests

# Default to DS-5 tool-chain
TOOL_CHAIN = gcc

# Core instantiated M0 Designstart
TBENCH_VC  = ../tbench_M0.vc

# Simulator type (mti/vcs/nc)
SIMULATOR  = vcs

# VCS option
VCS_OPTIONS    = -sverilog -v2k_generate +vcs+loopreport+1000 -debug_access+all -timescale=1ps/1ps +lint=all,noVCDE -full64 -diag timescale +notimingchecks -kdb -lca
VCS_SIM_OPTION = +lint=all,noVCDE -diag timescale +fsdbfile+sim.fsdb +notimingcheck +vcs+loopreport  
VCS_VC_OPTIONS = -f $(TBENCH_VC)
VERDI_PLI = -P $(VERDI_HOME)/share/PLI/VCS/LINUX64/novas.tab \
               $(VERDI_HOME)/share/PLI/VCS/LINUX64/pli.a
# Boot Loader image
BOOTLOADER  = bootloader

# Software make options
# - Pass onto the software makefile to define targetted CPU type
# You can append additional make options for testcode here
SW_MAKE_OPTIONS = CPU_PRODUCT=$(CPU_PRODUCT) TOOL_CHAIN=$(TOOL_CHAIN)


# ------- VCS -----------


set_env:
	export LD_LIBRARY_PATH=$(VERDI_HOME)/share/PLI/VCS/LINUX64:${LD_LIBRARY_PATH}
# Compile RTL
compile : set_env
	@mkdir -p sim
	@cd sim && $(MODULE) $(VERDI_MODULE) $(VCS_MODULE) && vcs $(VCS_OPTIONS) $(VERDI_PLI) $(VCS_VC_OPTIONS) 2>&1 | tee compile_vcs.log


# Run simulation in batch mode
# ADD code to recipe
run :   set_env
	@mkdir -p logs
	@cd sim && echo quit > quit.do
	@cd sim && $(MODULE) $(VCS_MODULE) $(VERDI_MODULE) && which verdi && ./simv $(VCS_SIM_OPTION) < quit.do | tee ../logs/run_$(TESTNAME).log ;

VERDI:  set_env
	cd sim && $(MODULE) $(VCS_MODULE) $(VERDI_MODULE) && verdi -ssf dump.fsdb &
# ------- Software -----------

# code target is used by other simulation targets (e.g. run_mti, sim_mti)
# Before simulation, bootrom and testcode need to be compiled.
code : testcode bootrom 

# Compile bootloader
# Note : The use of ls after compile allows the computing server to sync up
bootrom:
	@(cd ../testcodes/$(BOOTLOADER) ;\
	make all $(SW_MAKE_OPTIONS) ;\
	echo Compile done ;\
	ls > /dev/null ;\
	echo Copy $(BOOTLOADER).hex ;\
	if [ -e  $(BOOTLOADER).hex ] ; then \
	  cp $(BOOTLOADER).hex  ../../rtl_sim/$(BOOTLOADER).hex ;\
	else \
	  echo Wait for hex file ...;\
	  ls > /dev/null ;\
	  sleep 5 ; \
	  if [ -e  $(BOOTLOADER).hex ] ; then \
	    cp $(BOOTLOADER).hex  ../../rtl_sim/$(BOOTLOADER).hex ;\
	  else \
	    echo Problem reading hex file ;\
	    exit 1; \
	  fi ;\
	fi ;\
	cp $(BOOTLOADER).hex  ../../rtl_sim/$(BOOTLOADER).hex ;\
	cd ../../rtl_sim )

# Compile test code
# Note : The use of ls after compile allows the computing server to sync up
testcode:
ifeq ($(TESTNAME),)
	$(error Please specify TESTNAME on the make command line)
endif
	@(if [ -d "../testcodes/$(TESTNAME)" ] ; then \
	  cd ../testcodes/$(TESTNAME) ;\
	  make all $(SW_MAKE_OPTIONS) ; \
	  echo Compile done ;\
	  ls > /dev/null ;\
	  echo Copy $(TESTNAME).hex ;\
	  if [ -e  $(TESTNAME).hex ] ; then \
	    cp $(TESTNAME).hex ../../rtl_sim/image.hex ; \
	  else \
	    echo Wait for hex file ...; \
	    ls > /dev/null ;\
	    sleep 5 ; \
	    if [ -e  $(TESTNAME).hex ] ; then \
	      cp $(TESTNAME).hex ../../rtl_sim/image.hex ; \
	    else \
	      echo Problem reading hex file ;\
	      exit 1; \
	    fi ;\
	  fi ;\
	  cd ../../rtl_sim ;\
	else \
	  echo "ERROR: invalid TESTNAME value ( $(TESTNAME) )" ;\
	  exit 1 ;\
	fi ;\
	)


# Compile all software including boot ROM
compile_all_code: bootrom 
	for thistest in $(TEST_LIST) ; do \
	  echo Compiling $$thistest   ; \
	  echo Removing old image.hex ;\
	  rm -f image.hex  ;\
	  make testcode TESTNAME=$$thistest;\
	  if [ -e image.hex ] ; then \
            echo OK    - image.hex     created for test $$thistest ;\
	  else \
	    echo ERROR - image.hex NOT created for test $$thistest ;\
	    exit 1; \
	  fi ; \
	done



# Remove all software compilation results
clean_all_code:
	@(cd ../testcodes/$(BOOTLOADER) ; make clean; cd ../../rtl_sim; )
	for thistest in $(TEST_LIST) ; do \
	  echo Cleaning $$thistest ...  ; \
	  cd ../testcodes/$$thistest ; \
	  make clean; \
	  cd ../../rtl_sim; \
	done

# Remove only bootloader and default selected test
clean_code:
	@(cd ../testcodes/$(BOOTLOADER) ; make clean; cd ../../rtl_sim; )
	@(cd ../testcodes/$(TESTNAME)   ; make clean; cd ../../rtl_sim; )

# ------- clean -----------

# Remove RTL compile files, log files, software compile files
clean : clean_all_code
	@if [ -d work ] ; then \
	  rm -rf work ; \
	fi
	@if [ -e image.hex ] ; then \
	  rm image.hex ; \
	fi
	@if [ -e bootloader.hex ] ; then \
	  rm bootloader.hex ; \
	fi
	@if [ -d sim ] ; then \
	  rm -rf sim ; \
	fi
	@if [ -d logs ] ; then \
	  rm -rf logs ; \
	fi

	
