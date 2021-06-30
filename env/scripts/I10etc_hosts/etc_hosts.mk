#
# hosts.mk --- generate /etc/hosts
#

include ../common.mk

OK : /etc/hosts

/etc/hosts : $(hdb)
	sqlite3 -separator " " $(hdb) 'select ip_addr,group_concat(hostname, " ") from hosts group by ip_addr' > hosts
	$(kv_merge) /etc/hosts hosts > etc_hosts.0
	$(kv_merge) etc_hosts.0 hosts_to_fix_npm > etc_hosts.1
	$(inst) etc_hosts.1 /etc/hosts
