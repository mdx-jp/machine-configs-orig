#
# users.mk --- create taulec group and users
#
include ../common.mk

slapadd := slapadd
made_users_csv := made/users.csv
made_grps_csv  := made/grps.csv

ifeq ($(node_id),0)
  grps__ := $(shell sqlite3 $(udb) 'select grp from users')
  grps_  := $(shell for g in $(grps__); do slapcat -a "(&(cn=$${g})(objectClass=posixGroup))" | grep dn: > /dev/null || echo $${g} ; done)
  grps   := $(patsubst %,made/grps/%,$(grps_))
  users__ := $(shell sqlite3 $(udb) 'select user from users')
  users_  := $(shell for u in $(users__); do slapcat -a uid=$${u} | grep dn: > /dev/null || echo $${u} ; done)
  users   := $(patsubst %,made/users/%,$(users_))
  targets := $(made_users_csv) $(made_grps_csv)
else
  grps :=
  users :=
  targets := 
endif

OK : $(targets)

host_fqdn := $(shell sqlite3 $(hdb) "select hostname from hosts where node_id=0 and idx=0")
host_dc := $(shell python3 -c "print(','.join([ 'dc=%s' % x for x in '$(host_fqdn)'.split('.') ]))")
host_only := $(shell python3 -c "print('$(host_fqdn)'.split('.')[0])")

ldif/group_template.ldif : ldif/group_template.ldif.template
	sed -e "s/%host_fqdn%/$(host_fqdn)/g" -e "s/%host_dc%/$(host_dc)/g" -e "s/%host_only%/$(host_only)/g" ldif/group_template.ldif.template > ldif/group_template.ldif

ldif/user_template.ldif : ldif/user_template.ldif.template
	sed -e "s/%host_fqdn%/$(host_fqdn)/g" -e "s/%host_dc%/$(host_dc)/g" -e "s/%host_only%/$(host_only)/g" ldif/user_template.ldif.template > ldif/user_template.ldif

$(made_users_csv) : $(users)
	chmod 0600 $@

$(made_grps_csv) : $(grps)
	chmod 0600 $@

$(grps) : grp=$(notdir $@)
$(grps) : gid=$(shell        sqlite3 $(udb) 'select min(gid) from users where grp="$(grp)"')
$(grps) : % : ldif/group_template.ldif made/grps/created
	sed -e s/%GROUP%/$(grp)/g -e s/%GID%/$(gid)/g ldif/group_template.ldif | $(slapadd)
	echo "$(shell date),$(grp),$(gid)" >> $(made_grps_csv)

$(users) : user=$(notdir $@)
$(users) : uid=$(shell        sqlite3 $(udb) 'select uid     from users where user="$(user)"')
$(users) : grp=$(shell        sqlite3 $(udb) 'select grp     from users where user="$(user)"')
$(users) : gid=$(shell        sqlite3 $(udb) 'select gid     from users where user="$(user)"')
$(users) : home=$(shell       sqlite3 $(udb) 'select home    from users where user="$(user)"')
$(users) : mod=$(shell        sqlite3 $(udb) 'select mod     from users where user="$(user)"')
$(users) : db_pwd=$(shell     sqlite3 $(udb) 'select pwd     from users where user="$(user)"')
$(users) : db_sha_pwd=$(shell sqlite3 $(udb) 'select sha_pwd from users where user="$(user)"')
$(users) : pubkey=$(shell     sqlite3 $(udb) 'select pubkey  from users where user="$(user)"')
# if sha_pwd given in db, leave pwd empty; if db_pwd is given, use it, otherwise generate one
$(users) : pwd=$(shell if test -n "$(db_sha_pwd)" ; then echo "" ; else echo "$(db_pwd)" | grep . || pwgen 8 1; fi)
# if sha_pwd given in db, use it; otherwise sha plain pwd
$(users) : sha_pwd=$(shell echo $(db_sha_pwd) | grep . || slappasswd -s $(pwd))
$(users) : % : ldif/user_template.ldif made/users/created $(made_grps_csv) /usr/bin/pwgen
	sed -e s/%GROUP%/$(grp)/g -e s/%GID%/$(gid)/g -e s/%USER%/$(user)/g -e s/%UID%/$(uid)/g -e s:%HOME%:$(home):g -e s:%SHA_PASSWORD%:$(sha_pwd):g ldif/user_template.ldif | $(slapadd)
	if ! test -d $(home) ; then mkdir -p $(home) -m 0$(mod) ; chown $(uid):$(gid) $(home) ; fi
	./add_pubkey.sh $(home) $(uid) $(gid) "$(pubkey)"
	echo "$(shell date),$(user),$(uid),$(grp),$(gid),$(home),$(mod),$(pwd),$(sha_pwd),$(pubkey)" >> $(made_users_csv)
	echo -n > $@

/usr/bin/pwgen :
	$(aptinst) pwgen

made/grps/created made/users/created : % : 
	mkdir -p $@
