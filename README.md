# Odoo Container
This is an Odoo container image, you can use this as a base image for a more customized odoo image.

## Registry
```sh
docker pull ghcr.io/mplus-oss/odoo:<version>
```
`version` is the odoo branch that can be found in [Odoo repository](https://github.com/odoo/odoo).

## Odooctl Dependencies
```sh
pip install python-hcl2 PyYAML
```

## Odoo Configuration
This docker image is meant to be used with odooctl, An example Odoofile can be found in the root of this repository.

Instead of config file, you can use `config` scope to configure the container:
```hcl
odoo "15" {
  ...
  config = {
    options = {
      db_host = "10.10.10.10"
      db_user = "odoo"
      db_password = "odoo"
      workers = 3
    }
    queue_job = {
      channels = "root:1"
    }
  }
  ...
}
```
will correspond to:
```
[options]
db_host = 10.10.10.10
db_user = odoo
db_password = odoo
workers = 3

[queue_job]
channels = root:1
```

After that, run:

```sh
odooctl reconfigure
```

> Note 1: It's discouraged to change the values of `options.data_dir`.

> Note 2: For changing `options.addons_path`, add `server/addons` (or `s/addons`).

Also, there's additional environment variables to configure the container:
- `APT_INSTALL`: Space-separated list of packages to install.
- `ODOO_ARGS`: Additional arguments to pass to odoo, defaults to `--config=/opt/odoo/etc/odoo.conf`.
- `ODOO_DRY_RUN`: If set to anything, the container will not start odoo, but will initialize all the required things to run odoo in the container.
- `ODOO_DISABLE_TTY`: If set to anything, will disable screen.
- `ODOO_STAGE`: Marks the state of the service, particularly useful for prestart and poststop hooks, values are `init`, `update`, `start`
- `ONESHOT`: If set to anything, the container will run only once and will exit after the first start.
- `PIP_INSTALL`: Space-separated list of additional pip packages to install, mount a volume to `/opt/odoo/pip-cache` to avoid recompiling when restarting.
- `PIP_INSTALL_FILE`: The same as above but space-separated list of files to install.
> Note 3: If you're using `PIP_INSTALL` and `PIP_INSTALL_FILE` together, `PIP_INSTALL` will be installed first, and installed modules will be removed from `PIP_INSTALL_FILE`.
- `PURGE_CACHE`: If set to anything, the container will purge `__pycache__` in `/opt/odoo/extra-addons`
