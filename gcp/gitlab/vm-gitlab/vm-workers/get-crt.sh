#! /bin/sh
GITLAB_HOST="gitlab.dev-cehd.devsecops-cibanco.com"

openssl s_client \
    -showcerts -connect $GITLAB_HOST:443 -servername $GITLAB_HOST < /dev/null 2>/dev/null | openssl x509 -outform PEM > $GITLAB_HOST.crt

echo | openssl s_client \
    -CAfile $GITLAB_HOST.crt -connect $GITLAB_HOST:443 -servername $GITLAB_HOST


echo | openssl s_client \
    -CAfile $GITLAB_HOST.crt \
    -connect $GITLAB_HOST:443 -servername $GITLAB_HOST