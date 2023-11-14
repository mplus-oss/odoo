get_options() {
    grep -A999 "\[options\]" "/opt/odoo/etc/odoo.conf" | grep "$1" | awk -F'=' '{print $2}' | tr -d '[:space:]'
}

export PGHOST="$(get_options db_host)"
export PGPORT="$(get_options db_port)"
export PGUSER="$(get_options db_user)"
export PGPASSWORD="$(get_options db_password)"

cat << EOL

You're connected to Odoo instance

Overview of useful commands:

  $ soft-restart        Restarts Odoo server without losing container state
  $ purge-pycache       Purges pycache in extra-addons directory
  $ psql                Connects to database
  $ odoo-bin            Launches Odoo-bin directly

EOL