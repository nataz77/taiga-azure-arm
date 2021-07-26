#!/bin/bash

function setup_protected_service {
    cat <<EOF >> /etc/systemd/system/taiga-protected.service
[Unit]
Description=taiga_protected
After=network.target

[Service]
User=taiga
WorkingDirectory=/home/taiga/taiga-protected
ExecStart=/home/taiga/taiga-protected/.venv/bin/gunicorn --workers 4 --timeout 60 --log-level=info --access-logfile - --bind 0.0.0.0:8003 server:app
Restart=always
RestartSec=3

Environment=PYTHONUNBUFFERED=true

[Install]
WantedBy=default.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl start taiga-protected
    sudo systemctl enable taiga-protected
    if ! sudo systemctl status taiga-protected > /dev/null
    then
        echo 'Unable to install taiga-protected service. Please check the log above and retry'
    fi
}

function config_protected {
    cat<<EOF >> ~/taiga-protected/.env
SECRET_KEY=$TAIGA_SECRET
MAX_AGE=300
EOF
}

function main {
    cd ~
    git clone https://github.com/kaleidos-ventures/taiga-protected.git taiga-protected
    cd taiga-protected
    git checkout stable
    python3 -m venv .venv --prompt taiga-protected
    source .venv/bin/activate
    pip install --upgrade pip wheel
    pip install -r requirements.txt
    config_protected
    setup_protected_service
}

set -ex
echo "Taiga frontend install script starting @ `date` "
. ./helper_functions.sh
main
echo "Taiga frontend install script completed @ `date` "
set +ex