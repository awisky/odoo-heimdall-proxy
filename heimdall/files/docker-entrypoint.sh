#!/bin/bash
#
# ~ Copyright © 2024 Mountrix.com Company Limited. All Rights Reserved.
#

set -e

DOCKER_ENTRYPOINT_SLEEP=${DOCKER_ENTRYPOINT_SLEEP:-2}


sleep $(DOCKER_ENTRYPOINT_SLEEP) 2>/dev/null || true

eval "echo \"$0 ${action} (${HOSTNAME})\""

echo "Heimdall Configuration must be done already."


/bin/bash -c "eval /opt/heimdall/heimdall-entrypoint.sh"
