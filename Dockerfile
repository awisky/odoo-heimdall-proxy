FROM odoo:17.0
LABEL maintainer="Agustin Wisky. <agustin.wisky@mountrix.com>"

USER root
# Mount Customize /mnt/"addons" folders for users addons
RUN apt-get update && apt-get install --no-install-recommends -y \
#    openssh-server \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# RUN mkdir /var/run/sshd

WORKDIR /

# #allow remote access
# COPY ./rsa/id_rsa_remote.pub /root/.ssh/id_rsa_remote.pub
# RUN cat /root/.ssh/id_rsa_remote.pub > /root/.ssh/authorized_keys

# # Create known_hosts
# RUN touch /root/.ssh/known_hosts && ssh-keyscan github.com >> /root/.ssh/known_hosts
# # Create known_hosts and add github key
# RUN printf "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config \
#     && chmod -R 600 /root/.ssh/


RUN mkdir -p /mnt/mountrix/addons

ARG ODOO_USER_ADMIN_DEFAULT_PASSWORD

RUN mkdir -p /mnt/odoo

# Update aptitude with new repo
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    procps\
    vim\
    xmlstarlet && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python basics
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-utils\
        python3-dev\
        python3-wheel\
        wget\
        less\
        j2cli &&\
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# Install debugpy if you want to debug python code
RUN pip3 install --no-cache-dir debugpy

#install ohmybash
RUN bash -c "$(wget --progress=dot:giga https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"

COPY ./requirements.txt /mnt/odoo/

RUN pip3 install --no-cache-dir -r /mnt/odoo/requirements.txt

COPY ./addons /mnt/odoo/addons
COPY bootstrap.sh /etc/bootstrap.sh
RUN chmod a+x /etc/bootstrap.sh

COPY ./entrypoint.sh /
RUN chmod a+x /entrypoint.sh

COPY ./addons_external /mnt/odoo/addons_external
COPY ./addons_customer /mnt/odoo/addons_customer

RUN chown -R odoo /mnt/* && \
     chown -R odoo /var/lib/odoo

RUN mkdir -p /run/sshd; exit 0 && chmod 0755 /run/sshd
COPY ./config/odoo.conf.j2 /etc/odoo/odoo.conf.j2

EXPOSE 22
EXPOSE 8888

ENTRYPOINT ["/bin/sh","-c"]
CMD ["/etc/bootstrap.sh"]

