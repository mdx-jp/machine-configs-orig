#
# docker.mk 
#
include ../common.mk

OK : /usr/bin/docker

/usr/share/keyrings/docker-archive-keyring.gpg :
	apt-get update
	apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

/etc/apt/sources.list.d/docker.list :
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

/usr/bin/docker : /usr/share/keyrings/docker-archive-keyring.gpg /etc/apt/sources.list.d/docker.list
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io
