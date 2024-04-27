#
# ~ Copyright © 2024 Mountrix.com Company Limited.  All Rights Reserved.
#
FROM ubuntu:23.10

# for the Heimdall UI, only needed for the management server
EXPOSE 8087

# Postgres Port
EXPOSE 5432

ENV PYTHON_J2CLI_VER=0.3.10

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
            curl \
            wget \
            vim \
            htop \
            python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN set -x && \
    pip3 install  --no-cache --no-cache-dir \
      j2cli==${PYTHON_J2CLI_VER} --break-system-packages

RUN bash -c 'bash <(curl https://s3.amazonaws.com/s3.heimdalldata.com/hdinstall.sh) server'

COPY files /

ENTRYPOINT ["/docker-entrypoint.sh"]
