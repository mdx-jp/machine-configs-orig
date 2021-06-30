# build_env

This is a git repo to configure multiple VM instances of mdx

# For impatient ...

1. run several VM instances and obtain their addresses
1. ssh to one of them
1. git clone this repo, under /tmp
```
cd /tmp
git clone https://github.com/taura/build_env.git
```

4. configure hosts, users and packages
```
cd build_env/data
cp -p hosts.csv.template hosts.csv
cp -p users.csv.template users.csv
cp -p packages.csv.template packages.csv
```
and edit csv files as you need them. At minimum, you need to list IP addresses of the hosts.  See below for more details

5. GO!
```
cd /tmp/build_env
sudo apt install make sqlite3 # I wish them to be included in the template
make -f go.mk -j 10
```
The command `make -f go.mk -j 10` will first configure the VM you are in and then all other machines, up to10 machines concurrently.

# FILES

* env/scripts --- many sub-folders configuring software environment
* env/bin     --- small utilities to be used in scripts
* data/       --- where you have hosts and users info specific to your cluster
  * data/hosts.csv.template --- a template of host info (copied to hosts.csv)
  * data/users.csv.template --- a template of user info (copied to users.csv)
  * data/packages.csv.template --- a template of packages info (copied to packages.csv)

* when you extend your environment (e.g., when you add another piece of software), you may want to add a folder in env/scripts
  * you may fork this repo or get your contribution back to this repo if it is commonly useful
* otherwise you only need to have these csv files

# Philosophy

* a set of scripts to configure hosts _after they are up and running_
* rely only on makefiles, shell scripts and very basic sqlite3, which mere mortals can understand
* use make judiciously to prepare for failures
  * when some configs fail, fix the script and just run it again
  * each script directory can be run individually; just do
```
cd env/scripts/INNwhatever
sudo make -f whatever.mk -n  # to see what happens
sudo make -f whatever.mk
```  
  * when you run the whole thing again, part of the configs already succeeded are not repeated
```
cd env/scripts
sudo make
```  
  * when you add another piece of software later, add script and just run it again
```
cd env/scripts
sudo make
```  
  * this way you can enhance environments already running without rebuilding them from scratch every time you modify the environment

# data/hosts.csv

* copy data/hosts.csv.template to data/hosts.csv and edit it to reflect your cluster
* it should look like

```
node_id,idx,ip_addr,hostname,labels
0,0,2001:2f8:1041:1aa:250:56ff:feb0:663,taubun000.mdx.jp,
1,0,2001:2f8:1041:1aa:250:56ff:feb0:665,taubun001,
2,0,2001:2f8:1041:1aa:250:56ff:feb0:667,taubun002,
3,0,2001:2f8:1041:1aa:250:56ff:feb0:669,taubun003,
```

* a host is identified by node_id
* idx must be a sequence number per node_id; as a result (node_id,idx) must be a key that uniquely identifies a row
* idx can be used to have multiple rows per host, when a host has multiple IP addresses and/or hostnames
* `labels` column is used by `env/scripts/J20packages/packages.mk`to configure which packages are installed on which hosts (see below)
* you can add a new column as necessary, for example when you configure hosts differently
  * e.g., you add a column "slurm_compute" and set this column to 1 for hosts that will serve as slurm compute nodes
  * e.g., you add a column "desktop" and set this column to 1 for hosts that need desktop environment
* when you launch the configuration script, this CSV file is converted to an sqlite3 table named `hosts` so that you can query it with sqlite3 command from within your makefiles
```
sqlite3 DATABASE 'select distinct ip_addr from hosts'
```
* see env/scripts/I00db/db.mk for details

## data/users.csv

* copy data/users.csv.template to data/users.csv and edit it to reflect users of your cluster
* it should look like
```
date,user,uid,grp,gid,home,mod,sudo,pwd,sha_pwd,pubkey
,opam,9000,opam,9000,/home/opam,755,1,,,
,u10000,10000,u10000,10000,/home/u10000,750,1,,,
,u10001,10001,u10001,10001,/home/u10001,750,0,,,
```

* similarly to hosts.csv, this file is converted into an sqlite3 table called users in `env/scripts/I00db/db.mk`
* you can add new columns in case you configure users differently
* the database is then used by `env/scripts/I35users/users.mk`
* the user database is managed by LDAP (see `env/scripts/I15ldap/ldap.mk`)

* you can safely leave the `date` column empty
* meaning of columns `user`, `uid`, `grp`, `gid`, `home`, `mod` will be obvious
* the column `sudo` is 1 when you want to add this user to sudoers
* paste your OpenSSH public key to pubkey column. it looks like
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9s/2Uiy187pQvRTSNFnv5BQyFYyj9EVwOPx9/qLB2eugxTL1Pw+ViQ/QHwt0fNDYa/+KEHjhZnbcGRz0OJhQMDI4EJulU1aDVpqDPfFnFnwwzy1e+ghTH7cpbltEsJzCJd/TK9wziLbrrGnkxRKiKpnmTuiQg086zXF5F79caDpBdv0cTar+BIxESaXBcK58RWprsoWeu75AANdcKE/7EkBdUfXbMPV6wIc15Q6ByBf12MNVwlNMVR+AFKnstVEBdRGErlsChZHNGHeBIlsSF/XbG3PDK24n6hvibAtyezq+DNE7fSjsn21Zx80ggaEJeTWuB/TiOnA0e6KDpU2h3 tau@nanamomo
```
* if `sha_pwd` column is non-empty, it will be used to make your password entry in the user LDAP database.  A valid entry looks like
```
{SSHA}ebH7QYtCCzFuncoEoBdNdz9+jDQcO93R
```
and it can be generated by
```
slappasswd -s PLAIN_PASSWORD
```
It is useful when you do not want to leave plain text password on the machine (you presumably generate sha_pwd entries somewhere else (e.g., your local machine), save plain text passwords locally, and copy only SHA-encrypted passwords to the machine.
* if `sha_pwd` is empty but `pwd` is not, sha_pwd is generated by the above `slappasswd -s` command for you and is set to LDAP database
* if both `pwd` and `sha_pwd` are empty, a random password is generated and then SHA-encrypted
  * TODO: this behavior might be reconsidered later; allowing only public key login may be a better behavior
* in any case, `env/scripts/I35users/made_users.csv` is generated that lists all users' information including password
* TODO: any way to force the user to change the password first time s/he login?

## Eliminate plain passwords from the host

* after `env/scripts/I35users/users.mk` is run, it leaves plain passwords in the file `env/scripts/I35users/made_users.csv`
* the following files may contain user passwords in plain text
  * `env/scripts/I35users/made_users.csv` --- created by `env/scripts/I35users/users.mk`
  * `data/users.csv` --- created by you
  * `data/users.sqlite` --- created by `env/scripts/I00db/db.mk`
* if you bring `env/scripts/I35users/made_users.csv` back to your local PC and remove all three files from the VM, then the VM has no files containing users' passwords in plain text
* by default, users.mk runs only on the master (the VM you directly launched it on), so it will be created only on the master (no need to remove them on other machines)

* some time later, you may want to add new users, for which you may want to run users.mk again.  this is how things are supposed to work
  * write new users to users.csv (you may or may not have existing users in it)
  * run users.mk again
  * existing users are not configured; their passwords remain intact
  * information about newly added users will be appended to `env/scripts/I35users/made_users.csv`; so, if you have removed it after the last time you ran it, then this file will contain information only of the newly added users; otherwise, info about new users will be at the end of the file. information about existing users may or may not be accurate (they may have changed their passwords, etc.). in any event, users.mk won't affect existing users.

## data/packages.csv

* it is an easy interface to add a package to your environment
* the file looks like this

```
name,labels
python3-pip,1,
gcc,1,
g++,1,
gdb,1,
lv,1,
numactl,1,
```

* the `name` column is a package name
* `labels` column, which exist in `hosts` and `packages` table, control which packages are installed on which hosts
* a package P is installed on host H either when
  * P's `labels` column is empty, or
  * any label that appears in P's `labels` column also appears in the `labels` column of H
* for example, you can put labels such as 'client desktop gpu' to indicate this package should be installed on hosts which have either of the three labels. you perhaps put a label gpu in any host supporting gpu, etc.
