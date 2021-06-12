# What is django CMS?
[django CMS](https://www.django-cms.org/) is a free and open source content management system platform for publishing content on the World Wide Web and intranets. It is written in Django language framework, with Python.

(Source: [Wikipedia](https://en.wikipedia.org/wiki/Django_CMS))

# What's the Purpose of this Project?
**It provides a productive django CMS environment in a [Docker](https://www.docker.com/) container.**

It's based on the [official python image](https://github.com/docker-library/python) and utilizes the [django CMS Installer](https://djangocms-installer.readthedocs.io/en/latest/readme.html).

The resulting web site can be served with django's internal development server, but there's also a builtin option to use [gunicorn](https://gunicorn.org/) instead, which is more secure and stable and therefore useful for productive sites.

A [PostgreSQL database](https://www.postgresql.org/) is required in order to run this image. However, this requirement can easily be met using a [PostgreSQL Docker image](https://github.com/docker-library/postgres). The Docker Compose samples provided in this repository use this method.

# How to use this image?
## Requirements
In order to run this image, you need a [working installation of Docker](https://docs.docker.com/get-docker/).

Furthermore [Docker Compose](https://docs.docker.com/compose/install/) is recommended. Although it is possible to provide all arguments in Docker's command line interface, all documentation in this repository assumes that Docker Compose is installed.

## Setup the project
