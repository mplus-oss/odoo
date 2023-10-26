#!/usr/bin/env bash

echo -e "===> Starting Odoo Server\n"
python /opt/odoo/server/odoo-bin --pidfile /opt/odoo/server.pid --config /opt/odoo/etc/odoo.conf $@
echo -e "\n===> Stopping Odoo Server"