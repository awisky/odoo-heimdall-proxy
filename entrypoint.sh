#!/bin/bash

#render odoo configuration template
#export MODULES=`ls -ld /mnt/mountrix/addons/* |awk '{print $9}'| sed 's/$/,/g' | xargs echo | sed 's/, /,/g'`
j2 --undefined /etc/odoo/odoo.conf.j2 -o /etc/odoo/odoo.conf

set -e

if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then       
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

function test_modules() {
    echo "=====TESTING===="
    modules=$(find /mnt/odoo/addons/ -type d -exec test -e "{}/__manifest__.py" ';' -print | cut -d'/' -f5- | tr '\n' ','| sed 's/.$//')
    if [ ! -z "$modules" ]; then 
        modules=$modules
    else
        modules=base
    fi
    echo "Modules:" $modules
    exec /usr/bin/python3 /usr/bin/odoo "$@" "${DB_ARGS[@]}" -d test -i $modules --log-level=test --test-enable --stop-after-init
}

function debug_modules() {
    echo "=====Starting with debugger===="
    exec /usr/bin/python3 -m debugpy --listen 0.0.0.0:3001 /usr/bin/odoo "$@" "${DB_ARGS[@]}"
}

function check() {
if [ ! -z "$DEBUG" ]; then 
    debug_modules
elif [ ! -z "$TEST" ]; then
    test_modules
else
    exec odoo "$@" "${DB_ARGS[@]}" #--log-handler=odoo.addons.queue_job:DEBUG
fi
}

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            check
        else
            wait-for-psql.py ${DB_ARGS[@]} --timeout=30
            check
        fi
        ;;
    -*)
        wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        check
        ;;
    *)
        exec "$@"
esac

exit 1