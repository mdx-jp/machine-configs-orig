# I30etc_exports

```
make -f etc_exports.mk
```

* adds some entries to /etc/exports

* add nothing on the master (node_id = 0)
* add a line mounting the master's /home to its /home

* the necessity of this set up is to be discussed
* it is almost certain that we need to add entries to mount Lustre
* do we put users' home dirs in Lustre?