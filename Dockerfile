FROM traefik:1.7.4-alpine

RUN apk upgrade
RUN apk add --update \
    curl \
    libcurl \
    jq

# Copy data for add-on
COPY traefik.toml /
COPY prepare-config.sh /

RUN chmod +x /prepare-config.sh

ENTRYPOINT  ["/prepare-config.sh"]