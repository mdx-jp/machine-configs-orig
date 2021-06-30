# I25etc_fstab

```
make -f etc_fstab.mk
```

* adds some entries to /etc/fstab

* add nothing on the master (node_id = 0)
* add a line mounting the master's /home to its /home

* the necessity of this set up is to be discussed
* it is almost certain that we need to add entries to mount Lustre
* do we put users' home dirs in Lustre?