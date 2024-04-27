#!/bin/bash
echo "HOSTNAME:" $HOSTNAME
echo "DB HOST:" ${DB_PORT_5432_TCP_ADDR}
echo "Override default user admin password"
echo "ODOO_USER_ADMIN_DEFAULT_PASSWORD:" $ODOO_USER_ADMIN_DEFAULT_PASSWORD

ODOO_PATH=/usr/lib/python3/dist-packages/odoo
xmlstarlet edit --inplace --update '//odoo/data/record[@id="user_admin"]/field[@name="password"]/text()' --value "${ODOO_USER_ADMIN_DEFAULT_PASSWORD}" ${ODOO_PATH}/addons/base/data/res_users_data.xml


if [ ! -z "$TEST" ]; then
/entrypoint.sh odoo
else
/entrypoint.sh odoo
fi