#mode?=user
mode?=root
include ../../common.mk

all : OK

OK :
ifeq ($(mode),user)
	sudo $(apt) remove sosreport
	pip3 install --user sos sos-notebook
	python3 -m sos_notebook.install
else
	sudo $(apt) remove sosreport
	sudo pip3 install sos sos-notebook
	sudo python3 -m sos_notebook.install
endif
	touch $@
