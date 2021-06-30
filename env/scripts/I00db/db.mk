#
# db.mk --- make a database of hosts and users
# 
include ../common.mk

OK : $(hdb) $(udb)

$(hdb) : $(data_dir)/hosts.csv $(data_dir)/packages.csv
	rm -f $(hdb)
	echo -n | sqlite3 -separator , -cmd ".import $(data_dir)/hosts.csv hosts" $(hdb).bak
	echo -n | sqlite3 -separator , -cmd ".import $(data_dir)/packages.csv packages" $(hdb).bak
	chmod 0600 $(hdb).bak
	mv $(hdb).bak $(hdb)

$(udb) : $(data_dir)/users.csv
	rm -f $(udb)
	echo -n | sqlite3 -separator , -cmd ".import $(data_dir)/users.csv users" $(udb).bak
	chmod 0600 $(udb).bak
	mv $(udb).bak $(udb)
