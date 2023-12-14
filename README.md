# Odoo Container
This is an Odoo container image, you can use this as a base image for a more customized odoo image.

## Registry
```sh
docker pull registry.mitija.com/library/odoo:<version>
```
`version` is the odoo branch that can be found in [Odoo repository](https://github.com/odoo/odoo).

## Wkhtmltopdf

For the sake of image size, This image uses [Mwkhtmltopdf](https://github.com/mplus-oss/mwkhtmltopdf).
