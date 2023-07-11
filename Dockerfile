ARG ODOO_VERSION
FROM ghcr.io/mplus-oss/odoo:${ODOO_VERSION}-cloud

USER root
ARG S6_VERSION=3.1.3.0

# Install S6
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN set -ex ; \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz; \
    rm /tmp/s6-overlay-noarch.tar.xz /tmp/s6-overlay-x86_64.tar.xz; \
    mkdir -p /etc/services.d/odoo /etc/services.d/odootail

# Copy configurations
COPY ./src/cont-init.d/* /etc/cont-init.d/
COPY ./src/services.d/odoo/* /etc/services.d/odoo/
COPY ./src/services.d/odootail/* /etc/services.d/odootail/
COPY ./src/bin/* /usr/local/bin/
RUN set -ex; \
    chmod +x /usr/local/bin/* /etc/cont-init.d/* /etc/services.d/odoo/* /etc/services.d/odootail/*

# Set S6 environment variables
ENV \
    S6_KEEP_ENV=1 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    ODOOCONF__options__addons_path=server/addons \
    ODOOCONF__options__data_dir=data \
    ODOOCONF__options__logfile=logs/odoo.log \
    ODOOCONF__options__list_db=True \
    ODOO_STAGE=start \
    ODOOCONF=/opt/odoo/etc/odoo.conf

ENTRYPOINT [ "/init" ]
