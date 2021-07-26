#!/bin/bash

# Common functions definitions

function get_setup_params_from_configs_json
{
    local configs_json_path=${1}    # E.g., /var/lib/cloud/instance/configs.json

    # Wait for the cloud-init write-files user data file to be generated (just in case)
    local wait_time_sec=0
    while [ ! -f "$configs_json_path" ]; do
        sleep 15
        let "wait_time_sec += 15"
        if [ "$wait_time_sec" -ge "1800" ]; then
            echo "Error: Cloud-init write-files didn't complete in 30 minutes!"
            return 1
        fi
    done

    local json=$(cat $configs_json_path)
    export POSTGRES_USER=$(echo $json | jq -r .postgres.user)
    export POSTGRES_PASSWORD=$(echo $json | jq -r .postgres.password)
    export POSTGRES_HOST=$(echo $json | jq -r .postgres.host)
    export POSTGRES_PORT=$(echo $json | jq -r .postgres.port)
    export SECRET_KEY=$(echo $json | jq -r .secretkey)
    export TAIGA_URL=$(echo $json | jq -r .urls.taigaurl)
    export TAIGA_DOMAIN=$(echo $json | jq -r .urls.taigadomain)
    export ADMIN_EMAIL=$(echo $json | jq -r .admin.email)
    export ADMIN_NAME=$(echo $json | jq -r .admin.name)
    export RABBITMQ_USER=$(echo $json | jq -r .rabbitmq.user)
    export RABBITMQ_PASSWORD=$(echo $json | jq -r .rabbitmq.password)
    export RABBITMQ_HOST=$(echo $json | jq -r .rabbitmq.host)
    export RABBITMQ_PORT=$(echo $json | jq -r .rabbitmq.port)
    export EMAIL_FROM=$(echo $json | jq -r .email.from)
    export EMAIL_TLS=$(echo $json | jq -r .email.tls)
    export EMAIL_SSL=$(echo $json | jq -r .email.ssl)
    export EMAIL_HOST=$(echo $json | jq -r .email.host)
    export EMAIL_PORT=$(echo $json | jq -r .email.port)
    export EMAIL_USER=$(echo $json | jq -r .email.user)
    export EMAIL_PASSWORD=$(echo $json | jq -r .email.password)
}
