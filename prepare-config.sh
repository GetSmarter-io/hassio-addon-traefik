#!/bin/sh
set -e
echo "Start Prepare Traefik TOML"
CONFIG_PATH=/data/options.json
TOML_PATH="/traefik.toml"
 
# CONFIG_PATH="options_test.json"
# TOML_PATH="traefik.toml"


ACME=$(jq ".acme" ${CONFIG_PATH})
FILE=$(jq  ".file" ${CONFIG_PATH})
BASIC_AUTH=$(jq --raw-output  ".basicAuth" ${CONFIG_PATH})
ACME_ENABLED=$(echo $ACME | jq --raw-output ".enabled")
FILE_LENGTH=$(jq  ".file | length" ${CONFIG_PATH})
ADDITIONAL_TOML_ACME=""
ADDITIONAL_TOML_FILE_FRONTENDS=""
ADDITIONAL_TOML_FILE_BACKENDS=""
if [[ "${ACME_ENABLED}" == "true" ]]; then
    acme_email=$(echo ${ACME} | jq --raw-output ".email")
    acme_storage=$(echo ${ACME} | jq --raw-output ".storage")
    acme_caServer=$(echo ${ACME} | jq --raw-output ".caServer")
    acme_entryPoint=$(echo ${ACME} | jq --raw-output ".entryPoint")
    acme_onHostRule=$(echo ${ACME} | jq --raw-output ".onHostRule")

    ADDITIONAL_TOML_ACME="${ADDITIONAL_TOML_ACME}\n[acme]";
    ADDITIONAL_TOML_ACME="${ADDITIONAL_TOML_ACME}\n  email = \"${acme_email}\"";
    ADDITIONAL_TOML_ACME="${ADDITIONAL_TOML_ACME}\n  storage = \"${acme_storage}\"";
    ADDITIONAL_TOML_ACME="${ADDITIONAL_TOML_ACME}\n  caServer = \"${acme_caServer}\"";
    ADDITIONAL_TOML_ACME="${ADDITIONAL_TOML_ACME}\n  entryPoint = \"${acme_entryPoint}\"";
    ADDITIONAL_TOML_ACME="${ADDITIONAL_TOML_ACME}\n  onHostRule = \"${acme_onHostRule}\"";
fi


ADDITIONAL_TOML_FILE="${ADDITIONAL_TOML_FILE}\n[file]";
ADDITIONAL_TOML_FILE_FRONTENDS="${ADDITIONAL_TOML_FILE_FRONTENDS}\n[frontends]";
ADDITIONAL_TOML_FILE_BACKENDS="${ADDITIONAL_TOML_FILE_BACKENDS}\n[backends]";
for i in `seq 0 $((FILE_LENGTH-1))`;
do
    file_item=$(echo ${FILE} | jq ".[$i]")
    file_item_id=$(echo ${file_item} | jq --raw-output ".id")
    file_item_entryPoint=$(echo ${file_item} | jq --raw-output ".id")
    file_item_host=$(echo ${file_item} | jq --raw-output ".host")
    file_item_url=$(echo ${file_item} | jq --raw-output ".url")

    ADDITIONAL_TOML_FILE_FRONTENDS="${ADDITIONAL_TOML_FILE_FRONTENDS}\n  [frontends.$file_item_id]";
    ADDITIONAL_TOML_FILE_FRONTENDS="${ADDITIONAL_TOML_FILE_FRONTENDS}\n    backend = \"$file_item_id\"";
    ADDITIONAL_TOML_FILE_FRONTENDS="${ADDITIONAL_TOML_FILE_FRONTENDS}\n    entrypoints = [\"https\"]";
    ADDITIONAL_TOML_FILE_FRONTENDS="${ADDITIONAL_TOML_FILE_FRONTENDS}\n    [frontends.$file_item_id.routes.$file_item_id]";
    ADDITIONAL_TOML_FILE_FRONTENDS="${ADDITIONAL_TOML_FILE_FRONTENDS}\n      rule = \"Host: $file_item_host;\"";
  
    ADDITIONAL_TOML_FILE_BACKENDS="${ADDITIONAL_TOML_FILE_BACKENDS}\n  [backends.$file_item_id]";
    ADDITIONAL_TOML_FILE_BACKENDS="${ADDITIONAL_TOML_FILE_BACKENDS}\n    [backends.$file_item_id.servers.$file_item_id]";
    ADDITIONAL_TOML_FILE_BACKENDS="${ADDITIONAL_TOML_FILE_BACKENDS}\n      url = \"$file_item_url\"";

    if [[ "$ACME_ENABLED" == "true" ]]; then
        ADDITIONAL_TOML_ACME="${ADDITIONAL_TOML_ACME}\n[[acme.domains]]";
        ADDITIONAL_TOML_ACME="${ADDITIONAL_TOML_ACME}\n  main = \"$file_item_host\"";
    fi
done
ADDITIONAL_TOML_FILE="${ADDITIONAL_TOML_FILE}\n${ADDITIONAL_TOML_FILE_FRONTENDS}";
ADDITIONAL_TOML_FILE="${ADDITIONAL_TOML_FILE}\n${ADDITIONAL_TOML_FILE_BACKENDS}";


printf "$ADDITIONAL_TOML_ACME" >> ${TOML_PATH}
printf "$ADDITIONAL_TOML_FILE" >> ${TOML_PATH}



sed -i -e "s|###BASIC_AUTH###|$BASIC_AUTH|g" $TOML_PATH

cat /traefik.toml
echo "End Prepare Traefik TOML"
/entrypoint.sh