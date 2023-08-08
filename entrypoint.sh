#!/usr/bin/env bash

echo "===> Starting Odoo Server"
while python /opt/odoo/server/odoo-bin --config /opt/odoo/etc/odoo.conf $@; do
    echo "===> Restarting Odoo Server"
    sleep 1
done