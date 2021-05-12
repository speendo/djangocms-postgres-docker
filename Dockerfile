FROM python:3.9.4-slim-buster
MAINTAINER Marcel Jira <marcel.jira@gmail.com>

ENV PYTHONUNBUFFERED 1

ENV VIRTUAL_ENV=/app
WORKDIR $VIRTUAL_ENV
COPY resources .

RUN apt-get update; \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        libtiff-dev \
        libjpeg-dev \
        zlib1g-dev \
        libfreetype6-dev \
        python3-venv \
        python3-psycopg2 && \
    pip3 --no-cache-dir install -r lib/requirements.txt && \
    pip3 --no-cache-dir install -r /app/lib/djangocmsrequirements.txt && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lab/apt/lists/*;
    
# make directory
ENV project_name=djangocms
ENV project_dir=$VIRTUAL_ENV/projects

VOLUME $VIRTUAL_ENV
RUN mkdir $project_dir && \
    mkdir /var/www && \
    chown -R www-data:www-data $project_dir && \
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

RUN python3 -m venv $VIRTUAL_ENV --system-site-packages
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Finally, start the server
EXPOSE $internal_port
# STOPSIGNAL SIGTERM

VOLUME $VIRTUAL_ENV

CMD python3 scripts/runscript.py
