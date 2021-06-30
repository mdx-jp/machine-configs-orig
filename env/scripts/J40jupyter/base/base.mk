#mode?=user
mode?=root
ifeq ($(mode),user)
pip_inst:=pip3 install --user
else
pip_inst:=sudo pip3 install
endif

#### tornado==5.1.1
# nbconvert==5.6.1
# https://github.com/ipython-contrib/jupyter_contrib_nbextensions/issues/1529
pip_modules := tornado jupyter matplotlib jupyterlab jupyterhub notebook pixiedust

all : OK

include ../../common.mk
#  nodejs-legacy
OK : /usr/local/bin/configurable-http-proxy
	$(pip_inst) $(pip_modules)
	touch $@

/usr/local/bin/configurable-http-proxy :
	$(aptinst) npm
	sudo npm install -g configurable-http-proxy
