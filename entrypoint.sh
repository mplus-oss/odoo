#!/usr/bin/env bash

# Impliying that the CWD is /opt/odoo

base_path="/opt/odoo"
config_file="etc/odoo.conf"
addons_path=""
addons_extra_config=""

declare -A processed_addons

echo "===> Generating Nginx addons routing"
OLD_IFS="$IFS"
while IFS= read -r line; do
    if [[ "$line" == "addons_path"* ]]; then
        addons_path=${line#*=}
        addons_path=${addons_path//,/ }
        break
    fi
done < "$config_file"
IFS="$OLD_IFS"

for addons_sub_path in $addons_path; do
    for addon in $addons_sub_path/*; do
        if [[ -d "$addon" ]]; then
            addon_name="$(basename $addon)"
            if [[ -z "${processed_addons[$addon_name]}" && -d "$addon/static" ]]; then
                addons_extra_config="$addons_extra_config
location /$addon_name/static/ { alias $base_path/$addon/static/; expires 7d; add_header X-Served-From \"Static\"; }"
                processed_addons[$addon_name]=1
            fi
        fi
    done
done

echo "$addons_extra_config" > /etc/nginx/odoo/addons_path.conf

echo "===> Starting Nginx"
nginx -g "daemon off;" &
echo $$ > /run/nginx.pid

echo "===> Starting Odoo Server"
while /opt/odoo/server/odoo-bin --config /opt/odoo/etc/odoo.conf $@; do
    echo "Restarting Odoo Server"
    sleep 1
done

kill -TERM "$(cat /run/nginx.pid)"
