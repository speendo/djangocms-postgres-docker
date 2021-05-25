FROM python:3.9.4-slim-buster
MAINTAINER Marcel Jira <marcel.jira@gmail.com>

ENV PYTHONUNBUFFERED 1

ENV project_name=djangocms

ENV internal_port=8000
ENV use_gunicorn=yes
ENV gunicorn_number_of_workers=2

ENV init_i18n=yes
ENV init_use_tz=yes
ENV init_timezone=
ENV init_permissions=yes
ENV init_languages=
ENV init_bootstrap=no
ENV init_starting_page=no

ENV init_postgres_host=db
ENV init_db_port=5432

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=postgres

ENV POSTGRES_PASSWORD_FILE=

# Prepare template
ENV template_env=/template
ENV template_project_dir=$template_env/projects

# Prepare venv
ENV VIRTUAL_ENV=/app
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

ENV project_dir=$VIRTUAL_ENV/projects

# make directory and ensure correct permissions in template
RUN mkdir -p $template_project_dir && \
    mkdir /var/www && \
    chown -R www-data:www-data /var/www;

COPY resources $template_env

# install basic stuff
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        libtiff-dev \
        libjpeg-dev \
        zlib1g-dev \
        libfreetype6-dev \
        python3-venv \
        python3-psycopg2 && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lab/apt/lists/*;

RUN mv $template_env/scripts /scripts;
    
# Finally, start the server
EXPOSE $internal_port
# STOPSIGNAL SIGTERM

VOLUME $VIRTUAL_ENV
WORKDIR $VIRTUAL_ENV

CMD /scripts/startscript.sh;
