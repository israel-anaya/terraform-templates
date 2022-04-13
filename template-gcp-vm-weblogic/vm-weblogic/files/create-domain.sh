#! /bin/sh

../tools/weblogic-deploy/bin/createDomain.sh \
        -oracle_home $ORACLE_HOME \
        -domain_type WLS \
        -domain_parent $BASE_DOMAIN \
        -variable_file domain.properties \
        -model_file domain-model.yaml