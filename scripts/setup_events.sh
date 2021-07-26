#!/bin/bash

function setup_events_service {
    cat << EOF >> /etc/systemd/system/taiga-events.service
[Unit]
Description=taiga_events
After=network.target

[Service]
User=taiga
WorkingDirectory=/home/taiga/taiga-events
ExecStart=npm run start:production
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl start taiga-events
    sudo systemctl enable taiga-events
    if ! sudo systemctl status taiga-events > /dev/null
    then
        echo 'Unable to install taiga-events service. Please check the log above and retry'
    fi
}

function config_events {
    cat <<EOF >> ~/taiga-events/.env
RABBITMQ_URL="'amqp://$RABBITMQ_USER:$RABBITMQ_PASSWORD@$RABBITMQ_HOST:$RABBITMQ_PORT/taiga'"
SECRET="'$SECRET_KEY'"
WEB_SOCKET_SERVER_PORT=8888
APP_PORT=3023
EOF
}

function main {
    cd ~
    git clone https://github.com/kaleidos-ventures/taiga-events.git taiga-events
    cd taiga-events
    git checkout stable
    npm install
    config_events
    setup_events_service
}

set -ex
echo "Taiga events install script starting @ `date` "
. ./helper_functions.sh
main
echo "Taiga events install script completed @ `date` "
set +ex