#!/bin/bash

function config_frontend {
    cat <<EOF >> ~/taiga-front-dist/dist/conf.json
{
	"api": "https://$TAIGA_DOMAIN/api/v1/",
	"eventsUrl": "wss://$TAIGA_DOMAIN/events",
	"debug": "true",
	"publicRegisterEnabled": true,
	"feedbackEnabled": true,
	"privacyPolicyUrl": null,
	"termsOfServiceUrl": null,
	"GDPRUrl": null,
	"maxUploadFileSize": null,
	"contribPlugins": []
}
EOF
}

function main {
    cd ~
    git clone https://github.com/kaleidos-ventures/taiga-front-dist.git taiga-front-dist
    cd taiga-front-dist
    git checkout stable
    config_frontend
}

set -ex
echo "Taiga frontend install script starting @ `date` "
. ./helper_functions.sh
main
echo "Taiga frontend install script completed @ `date` "
set +ex