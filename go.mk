#
# go.mk
#
this_repo_url := https://github.com/taura/build_env.git
git_dir := $(shell basename $(shell pwd) .git)

user := mdxuser

ssh := ssh -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' 
scp := scp -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' 
apt := DEBIAN_FRONTEND=noninteractive apt -q -y -o DPkg::Options::=--force-confold
db := :memory: -separator , -cmd ".import data/hosts.csv hosts" 

slave_ids := $(shell sqlite3 $(db) 'select distinct node_id from hosts where node_id > 0')
config_slaves := $(addprefix configs/,$(slave_ids))

all : config_all

config_local :
	cd env/scripts && sudo make

$(config_slaves) : ip_addr=$(shell sqlite3 $(db) 'select ip_addr from hosts where node_id=$* and idx=0')
$(config_slaves) : cur_dir_base=$(shell basename $(shell pwd))
$(config_slaves) : configs/% : configs/0
	$(ssh) $(user)@$(ip_addr) sudo $(apt) install make sqlite3 git
	$(ssh) $(user)@$(ip_addr) "if test -d /tmp/$(git_dir) ; then git -C /tmp/$(git_dir) pull ; else git -C /tmp clone $(this_repo_url) ; fi"
	$(scp) data/*.csv $(user)@[$(ip_addr)]:/tmp/$(git_dir)/data/
	$(ssh) $(user)@$(ip_addr) make -C /tmp/$(git_dir) -f go.mk config_local > $@.tmp
	mv $@.tmp $@

configs/0 : configs/created
	$(MAKE) -f go.mk config_local

configs/created :
	mkdir -p $@

config_all : configs/0 $(config_slaves)
