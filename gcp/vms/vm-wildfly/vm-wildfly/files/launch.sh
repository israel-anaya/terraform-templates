#!/bin/bash

if [ "x$WILDFLY_HOME" = "x" ]; then
    WILDFLY_HOME="/opt/wildfly"
fi

echo "Path: $WILDFLY_HOME"

if [[ "$1" == "domain" ]]; then
    $WILDFLY_HOME/bin/domain.sh -c $2 -b $3 -bmanagement $4 -Djboss.http.port=$5
else
    $WILDFLY_HOME/bin/standalone.sh -c $2 -b $3 -bmanagement $4 -Djboss.http.port=$5
fi