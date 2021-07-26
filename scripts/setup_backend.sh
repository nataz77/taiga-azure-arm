#!/bin/bash

function setup_taiga_service {
    cat << EOF >> /etc/systemd/system/taiga.service
[Unit]
Description=taiga_back
After=network.target

[Service]
User=taiga
WorkingDirectory=/home/taiga/taiga-back
ExecStart=/home/taiga/taiga-back/.venv/bin/gunicorn --workers 4 --timeout 60 --log-level=info --access-logfile - --bind 0.0.0.0:8001 taiga.wsgi
Restart=always
RestartSec=3

Environment=PYTHONUNBUFFERED=true
Environment=DJANGO_SETTINGS_MODULE=settings.config

[Install]
WantedBy=default.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl start taiga
    sudo systemctl enable taiga

    if ! sudo systemctl status taiga > /dev/null
    then
        echo 'Unable to install taiga service, please check the log above and retry'
    fi

cat << EOF >> /etc/systemd/system/taiga-async.service
[Unit]
Description=taiga_async
After=network.target

[Service]
User=taiga
WorkingDirectory=/home/taiga/taiga-back
ExecStart=/home/taiga/taiga-back/.venv/bin/celery -A taiga.celery worker -B --concurrency 4 -l INFO
Restart=always
RestartSec=3
ExecStop=/bin/kill -s TERM $MAINPID

Environment=PYTHONUNBUFFERED=true
Environment=DJANGO_SETTINGS_MODULE=settings.config

[Install]
WantedBy=default.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl start taiga-async
    sudo systemctl enable taiga-async
    if ! sudo systemctl status taiga-async > /dev/null
    then
        echo 'Unable to install taiga-async service, please check the log above and retry'
    fi
}

function main {
    export DEBIAN_FRONTEND=noninteractive
    cd ~
    git clone https://github.com/kaleidos-ventures/taiga-back.git taiga-back
    cd taiga-back
    git checkout stable
    python3 -m venv .venv --prompt taiga-back
    source .venv/bin/activate
    pip install --upgrade pip wheel
    pip install -r requirements.txt
    pip install git+https://github.com/kaleidos-ventures/taiga-contrib-protected.git@6.0.0#egg=taiga-contrib-protected
    cp /var/lib/cloud/instance/config.py settings/config.py
    source .venv/bin/activate
    export DJANGO_SETTINGS_MODULE=settings.config
    python manage.py migrate --noinput
    python manage.py createsuperuser
    python manage.py loaddata initial_project_templates
    python manage.py compilemessages
    python manage.py collectstatic --noinput

    setup_taiga_service

    
}

set -ex
echo "Taiga backend install script starting @ `date` "
. ./helper_functions.sh
main
echo "Taiga backend install script completed @ `date` "
set +ex