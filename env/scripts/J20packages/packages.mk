#
# packages.mk --- install packages
#
include ../common.mk

host_labels := $(shell sqlite3 $(hdb) 'select labels from hosts where node_id=$(node_id)')
cond := labels="" $(foreach l,$(host_labels),or labels like "$(l)" or labels like "$(l) %" or labels like "% $(l) %" or labels like "% $(l)")
pkgs := $(shell sqlite3 $(hdb) 'select name from packages where $(cond)')

OK : $(pkgs)

$(pkgs) : % : do_install

do_install :
	$(apt) update
	$(aptinst) $(pkgs)
	$(apt) upgrade
