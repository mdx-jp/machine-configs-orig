# J20packages

```
make -f packages.mk
```

* installs a whole bunch of apt packages

* for things you can install just with apt, just add your packages to `../../../data/packages.csv`
* `labels` column, which exist in `hosts` and `packages` table, control which packages are installed on which hosts
* a package P is installed on host H either when
  * P's `labels` column is empty, or
  * any label that appears in P's `labels` column also appears in the `labels` column of H
* for example, you can put labels such as 'client desktop gpu' to indicate this package should be installed on hosts which have either of the three labels. you perhaps put a label gpu in any host supporting gpu, etc.