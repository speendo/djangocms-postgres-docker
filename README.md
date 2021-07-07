# What is django CMS?
[django CMS](https://www.django-cms.org/) is a free and open source content management system platform for publishing content on the World Wide Web and intranets. It is written in Django language framework, with Python.

(Source: [Wikipedia](https://en.wikipedia.org/wiki/Django_CMS))

# What's the Purpose of this Project?
**It provides a productive django CMS environment in a [Docker](https://www.docker.com/) container.**

It's based on the [official python image](https://github.com/docker-library/python) and utilizes the [django CMS Installer](https://djangocms-installer.readthedocs.io/en/latest/readme.html).

The resulting web site can be served with django's internal development server, but there's also a builtin option to use [gunicorn](https://gunicorn.org/) instead, which is more secure and stable and therefore useful for productive sites.

A [PostgreSQL database](https://www.postgresql.org/) is required in order to run this image. However, this requirement can easily be met using a [PostgreSQL Docker image](https://github.com/docker-library/postgres). The Docker Compose samples provided in this repository use this method.

# Tags
* `3.9.0`, `3.9`, `3`, `latest` - django CMS 3.9.0

# How to use this image?
## Requirements
In order to run this image, you need a [working installation of Docker](https://docs.docker.com/get-docker/).

Furthermore [Docker Compose](https://docs.docker.com/compose/install/) is recommended. Although it is possible to provide all arguments in Docker's command line interface, all documentation in this repository assumes that Docker Compose is installed.

## Setup the project
1. **Optional:** Clone this repository
2. Copy one of the docker-compose examples in [docker-compose_examples](docker-compose_examples/) (preferably start with [docker-compose_default.yml](docker-compose_examples/docker-compose_default.yml) unless you need one of the features adressed in the other examples) to `docker-compose.yml`
3. Create a file `env/djangocms.env` with parameters from [`djangocms.env`](#djangocmsenv)
4. Create a file `env/postgres.env` with parameters from [`postgres.env`](#postgresenv)
5. Create a folder `secrets/` and put the following files inside this folder
  * `postgres_db.txt` containing a string with the name of your PostgreSQL database (not to be mixed up with the host name)
  * `postgres_user.txt` containing the username to access your PostgreSQL database
  * `postgres_password.txt` containing the user password for the user to access your PostgreSQL database
6. Start a shell, navigate to the project folder and run `docker-compose up -d`
7. Once the container is created and ready, you should be able to access your Django CMS installation on your browser at http://localhost:8000

# Features and How-Tos
## Configure a new project
When the Docker container is started, it first checks if the file `/app/bin/activate` is present. If it's not present the system assumes that the system needs to be configured and will setup a [venv](https://docs.python.org/3/library/venv.html) in the `/app/` folder. Furthermore it will install several requirements to run django CMS.

After that the startup script checks if the folder `/app/projects/` is present. If it's presemt already, the system assumes that this is either not the first boot of the system or that you try to migrate from another installation and will skip the setup process. Otherwise a new django CMS project will be initialized in `/app/projects/<project_name>/` (where `<project_name>` is an environment variable - see [below](#djangocmsenv)).

## Migrating and upgrading
Sometimes you might want to migrate an existing project to a new docker container, e.g. when upgrading to a newer version. To perform a migration of an existing project (stored in `/your/host/path/projects/<project_name>`) make sure that the Docker container recognizes the folder `/your/host/path/projects` as `/app/projects`. A good way to achieve this to mount the host folder `/your/host/path` to `/app` in the container. Your `docker-compose.yml` should look like this

    app:
      [...]
      volumes:
        - /your/host/path:/app
      [...]

## Install additional Linux and Python packages
In principle you can modify the system to your needs by logging into the container and performing the changes you desire. However, this procedure is not optimal as these changes won't sustain typical procedures (like upgrading the Docker image). As the more likely changes are limited to enhance the container's features with additional Linux and/or Python packages, the image provides ways to permanently add those.
### Linux packages
This image is based on Debian Stable. In order to add a Debian package, modify `/app/req/user_debianpackages.txt` and add one package per line. The package shall be installed when restarting the Docker container.
### Python packages
In order to add a Python package, modify `/app/req/pythonpackages.txt` and add one package per line. The package shall be installed (using `pip`) when restarting the Docker container.

# Environment Variables
Environment variables are stored in the `env` folder and split up into `postgres.env` (covering database options) and `djangocms.env` (covering everything else). With a little knowledge in Docker compose, you could also specify those parameters directly in the Docker compose file. Personally, I prefer to keep those parameters in seperate files.
## djangocms.env
**project_name** (*default=djangocms*)  
See *project_name* in the [django CMS Installer Argument reference](https://djangocms-installer.readthedocs.io/en/latest/reference.html)

**init_i18** (*default=yes*)  
See *i18* in the [django CMS Installer Argument reference](https://djangocms-installer.readthedocs.io/en/latest/reference.html)

**init_use_tz** (*default=yes*)  
See *use_tz* in the [django CMS Installer Argument reference](https://djangocms-installer.readthedocs.io/en/latest/reference.html)

**init_timezone** (*no default*)  
See *timezone* in the [django CMS Installer Argument reference](https://djangocms-installer.readthedocs.io/en/latest/reference.html)

**init_permissions** (*default=yes*)  
See *permissions* in the [django CMS Installer Argument reference](https://djangocms-installer.readthedocs.io/en/latest/reference.html)

**init_languages** (space seperated, *no default*)  
See *languages* in the [django CMS Installer Argument reference](https://djangocms-installer.readthedocs.io/en/latest/reference.html), take care to specify a *space seperated list* as opposed to a comma seperated list in django CMS Installer calls

**init_bootstrap** (*default=no*)  
See *bootstrap* in the [django CMS Installer Argument reference](https://djangocms-installer.readthedocs.io/en/latest/reference.html)

**init_starting-page** (*default=no*)  
See *starting-page* in the [django CMS Installer Argument reference](https://djangocms-installer.readthedocs.io/en/latest/reference.html)

**use_gunicorn** (yes|no, *default=yes*)  
Choose `no` to use the internal development server or `yes` to use gunicorn instead. Gunicorn is safer and recommended to be used on productive pages, however the internal server is much more convenient for development.  
*Different to other parameters, this parameter can be changed whenever you restart the docker container*

**gunicorn_number_of_workers** (number, *default=2*)  
See [https://docs.gunicorn.org/en/stable/run.html#commonly-used-arguments](https://docs.gunicorn.org/en/stable/run.html#commonly-used-arguments) `--workers`  
*Different to other parameters, this parameter can be changed whenever you restart the docker container*

**internal_port** (number, *default=8000*)  
The port inside of the docker container the (gunicorn or development) server listens. Actually I can see no practical reason to change this. However, if you do, make sure to keep it aligned with your `docker-compose.yml`  
*Different to other parameters, this parameter can be changed whenever you restart the docker container*

**init_postgres_host** (string, *default=db*)
The hostname of your PostgreSQL database

**init_db_port** (number, *default=5432*)
The port that your PostgreSQL database listens

## postgres.env
See [https://github.com/docker-library/docs/tree/master/postgres#environment-variables](https://github.com/docker-library/docs/tree/master/postgres#environment-variables)
