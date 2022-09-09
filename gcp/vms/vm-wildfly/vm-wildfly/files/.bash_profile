#! /bin/bash

if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

export WILDFLY_HOME="/opt/wildfly"
 
# Configure JAVA_HOME
export JAVA_HOME="/usr/lib/jvm/jdk1.8.0_321"

