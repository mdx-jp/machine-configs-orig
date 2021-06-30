#
# jupyter.mk --- install various jupyter modules
#
include ../common.mk

# vpython ocaml 
subdirs := c bash nbgrader sos
targets := $(addsuffix /OK,$(subdirs))

OK : $(targets)

$(targets) : %/OK : base/OK
	cd $* && $(MAKE) -f $*.mk

base/OK : %/OK : 
	cd $* && $(MAKE) -f $*.mk
