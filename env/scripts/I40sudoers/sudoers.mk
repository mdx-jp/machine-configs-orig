#
# sudoers.mk
#
include ../common.mk

OK : /etc/sudoers.d/sudoers_file

/etc/sudoers.d/sudoers_file : sudoers_file
	$(inst) -m 440 sudoers_file /etc/sudoers.d/

sudoers_file : $(udb)
	sqlite3 $(udb) 'select user || " ALL=(ALL) NOPASSWD:ALL" from users where sudo = 1' > $@.bak
	mv $@.bak $@
