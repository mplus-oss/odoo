#!/usr/bin/env bash

attempt_restart="true"

while $attempt_restart; do
    echo -e "$(date +"%Y-%m-%d %H:%M:%S,%3N") Starting Odoo Server\n"
    # shellcheck disable=SC2068
    python /opt/odoo/server/odoo-bin --pidfile /opt/odoo/server.pid --config /opt/odoo/etc/odoo.conf $@
    echo -e "$(date +"%Y-%m-%d %H:%M:%S,%3N") Odoo Server stopped\n"
    attempt_restart="false"
    if [[ -f /opt/odoo/soft-restart ]]; then
        rm /opt/odoo/soft-restart
        attempt_restart="true"
    fi
done