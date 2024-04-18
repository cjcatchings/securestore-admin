#!/bin/sh
#cp /ssefs/server.keystore /opt/keycloak/conf/.
/opt/keycloak/bin/kc.sh start --https-key-store-file=/opt/keycloak/conf/server.keystore --https-key-store-password=$KS_PW --import-realm
