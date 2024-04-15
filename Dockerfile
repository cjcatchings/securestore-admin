FROM quay.io/keycloak/keycloak:latest as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak
RUN mkdir -p /opt/keycloak/data/import
COPY import/secstorerealm.json /opt/keycloak/data/import
COPY conf/server.keystore /opt/keycloak/conf/server.keystore
#RUN keytool -genkeypair -storepass ${KS_PW} -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
# TODO - replace with your own cert
# for demonstration purposes only, please make sure to use proper certificates in production instead
#COPY server.keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# change these values to point to a running postgres instance
ENV KC_DB=postgres
ENV KS_PW=$KS_PW
#RUN cp /efs/server.keystore /opt/keycloak/conf.
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--https-key-store-file=/opt/keycloak/conf/server.keystore", "--https-key-store-password=${KS_PW}", "--import-realm"]
