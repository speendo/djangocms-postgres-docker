FROM python:3.9.4-slim-buster
MAINTAINER Marcel Jira <marcel.jira@gmail.com>

ENV PYTHONUNBUFFERED 1

ENV template_env=/template

COPY resources $template_env

RUN mkdir /startupScripts && \
    mv $template_env/scripts/movetemplate.py /startupScripts/ && \
    mv $template_env/scripts/runscript.py /startupScripts/ && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        libtiff-dev \
        libjpeg-dev \
        zlib1g-dev \
        libfreetype6-dev \
        python3-venv \
        python3-psycopg2 && \
    pip3 --no-cache-dir install -r $template_env/req/requirements.txt && \
    pip3 --no-cache-dir install -r $template_env/req/djangocmsrequirements.txt && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lab/apt/lists/*;
    
# make directory
ENV project_name=djangocms

ENV template_project_dir=$template_env/projects

RUN mkdir $template_project_dir && \
    mkdir /var/www && \
    chown -R www-data:www-data $template_project_dir && \
    chown -R www-data:www-data /var/www;

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

# Activate venv
ENV VIRTUAL_ENV=/app
# RUN python3 -m venv $VIRTUAL_ENV --system-site-packages
# Because a bind mount to $VIRTUAL_ENV would obscure $VIRTUAL_ENV, this has to be done later in "movetemplate.py"
# Also see https://docs.docker.com/storage/bind-mounts/#mount-into-a-non-empty-directory-on-the-container
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

ENV project_dir=$VIRTUAL_ENV/projects

# Finally, start the server
EXPOSE $internal_port
# STOPSIGNAL SIGTERM

VOLUME $VIRTUAL_ENV
WORKDIR $VIRTUAL_ENV

CMD python3 /startupScripts/runscript.py
