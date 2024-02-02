ARG \
    PYTHON_VERSION
FROM python:${PYTHON_VERSION}-bookworm as builder
ARG \
    DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
COPY ./odoo/requirements.txt /tmp/requirements.txt
RUN set -ex; \
    apt update; \
    apt upgrade -y; \
    apt install --no-install-recommends -y \
        git \
        file \
        curl \
        util-linux \
        libxslt-dev \
        libzip-dev \
        libldap2-dev \
        libsasl2-dev \
        libpq-dev \
        libjpeg-dev \
        gcc \
        g++ \
        build-essential;
RUN pip wheel -r /tmp/requirements.txt phonenumbers --wheel-dir /usr/src/app/wheels    

FROM python:${PYTHON_VERSION}-bookworm as runner
LABEL org.opencontainers.image.authors="Syahrial Agni Prasetya <syahrial@mplus.software>"
LABEL org.opencontainers.image.licenses="LGPL-3.0"
LABEL org.opencontainers.image.vendor="M+ Software"
LABEL org.opencontainers.image.title="Odoo"
LABEL org.opencontainers.image.description="Open Source ERP and CRM"
ARG \
    DEBIAN_FRONTEND=noninteractive \
    NODEJS_VERSION=20 \
    WKHTMLTOPDF_VERSION=0.12.6.1-2
ENV PYTHONUNBUFFERED=1

# Install Odoo Dependencies
COPY --from=builder /usr/src/app/wheels  /wheels/
RUN set -ex; \
    apt update; \
    apt upgrade -y; \
    apt install --no-install-recommends -y \
        git \
        file \
        curl \
        screen \
        util-linux \
        vim \
        zstd \
        pspg \
        htop; \
    pip install --no-cache-dir --no-index --find-links=/wheels/ /wheels/*; \
    rm -rf /wheels/

# Install PostgreSQL client
RUN set -ex; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/pgdg.gpg; \
    . /etc/os-release; \
    echo "deb [signed-by=/etc/apt/keyrings/pgdg.gpg] https://apt.postgresql.org/pub/repos/apt ${VERSION_CODENAME}-pgdg main" > /etc/apt/sources.list.d/pgdg.list; \
    apt update; \
    apt install -y postgresql-client

# Install Wkhtmltopdf
COPY --from=registry.mitija.com/library/mwkhtmltopdf-client:latest /usr/local/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf

# Install NodeJS
RUN set -ex; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODEJS_VERSION}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list; \
    apt update; \
    apt install -y --no-install-recommends \
        nodejs; \
    npm install -g rtlcss less@3.0.4

# Install Odoo
ENV PIP_CACHE_DIR /opt/odoo/pip-cache
RUN set -ex; \
    mkdir -p /opt/odoo/logs /opt/odoo/data /opt/odoo/etc /opt/odoo/pip-cache /opt/odoo/extra-addons; \
    cd /opt/odoo; \
    ln -sf server s; ln -sf extra-addons e; \
    useradd -d /opt/odoo odoo -s /bin/bash; \
    chown -R odoo:odoo /opt/odoo
COPY --chown=odoo:odoo ./odoo /opt/odoo/server

# Copy configuration
COPY ./src/entrypoint.sh /entrypoint.sh
COPY --chown=odoo:odoo ./src/.bashrc /opt/odoo/.bashrc

# Copy scripts
COPY ./src/bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Copy https://github.com/mplus-oss/cloud-addons
COPY --chown=odoo:odoo ./cloud-addons /opt/odoo/server/cloud-addons

# EXPOSE doesn't actually do anything, it's just gives metadata to the container
EXPOSE 8069 8072

# Set cwd
WORKDIR /opt/odoo

# Set user
USER odoo

# Run Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
