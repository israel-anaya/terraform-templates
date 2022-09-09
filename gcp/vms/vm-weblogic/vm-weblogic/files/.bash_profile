#! /bin/bash

if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

export ORACLE_HOME="/home/oracle/middleware"
export BASE_DOMAIN="/home/oracle/domains"
export MW_HOME=/home/oracle/middleware 
export WL_HOME=$WLS_HOME
export WLS_HOME=$MW_HOME/wlserver
 
# Configure JAVA_HOME
export JAVA_HOME="/usr/lib/jvm/jdk1.8.0_321"

# source $ORACLE_HOME/wlserver/server/bin/setWLSEnv.sh