#!/usr/bin/env bash

attempt_restart="true"

while $attempt_restart; do
    echo -e "===> Starting Odoo Server\n"
    python /opt/odoo/server/odoo-bin --pidfile /opt/odoo/server.pid --config /opt/odoo/etc/odoo.conf $@
    echo -e "\n===> Stopping Odoo Server"
    attempt_restart="false"
    if [[ -f /opt/odoo/soft-restart ]]; then
        rm /opt/odoo/soft-restart
        attempt_restart="true"
    fi
done