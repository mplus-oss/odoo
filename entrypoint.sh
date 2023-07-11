#!/bin/sh

# Impliying that the CWD is /opt/odoo

base_path="/opt/odoo"
config_file="etc/odoo.conf"
addons_path=""
addons_extra_config=""

echo "===> Generating Nginx addons routing"
OLD_IFS="$IFS"
while IFS= read -r line; do
    if [ $line == addons_path* ]; then
        addons_path=${line#*=}
        addons_path=${addons_path//,/ }
        break
    fi
done < "$config_file"
IFS="$OLD_IFS"

for addons_sub_path in $addons_path; do
    for addon in $addons_sub_path/*; do
        if [ -d "$addon" ]; then
            addons_extra_config="$addons_extra_config
                location /$addon/static/ { alias $base_path/extra-addons/$addon/static/; }"
        fi
    done
done

sed -i "s#{{{addons_extra_config}}}#$addons_extra_config#g" /etc/nginx/nginx.conf

echo "===> Starting Nginx"
nginx -g "daemon off;" &
echo $$ > /run/nginx.pid

echo "===> Starting Odoo Server"
while runuser -u odoo -- /opt/odoo/server/odoo-bin $@; do
    echo "Restarting Odoo Server"
    sleep 1
done

kill -TERM "$(cat /run/nginx.pid)"