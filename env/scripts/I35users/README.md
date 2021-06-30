# I35users

```
make -f users.mk
```

* makes groups and users and updates LDAP database (see `../I15ldap`)

* user information comes from ../../../data/users.csv -> ../../../data/users.sqlite 
* it assumes user/group databases are managed by LDAP
* if a user already exists (checked by slapcat -a 'uid=USER_NAME'), then nothing happens on that user
* for users that do not exist, the user is created and its password set
* the password comes from `sha_pwd` and `pwd` columns
  * if `sha_pwd` is not empty, `pwd` entry is ignored and it is used as a SHA-encrypted password set in LDAP database
  * if `sha_pwd` is empty but `pwd` is not, then `pwd` is used as the plain text password
  * if both `sha_pwd` and `pwd` are empty, then a random password is generated (TODO: reconsider this behavior)
* if `pubkey` is not empty, `~/.ssh/authorized_keys` is created whose contents is it

* information about the newly created users is written to `made/users.csv`, with empty `pwd` columns filled with the generated passwords
* after you are done, you will presumably want to bring `made/users.csv` back to your local PC to let the users know their initial passwords and then remove that file from the configured host
* you also want to remove ../../../data/users.{csv,sqlite}
