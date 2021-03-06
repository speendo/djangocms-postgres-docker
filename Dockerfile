FROM python:3.9.1-slim-buster
MAINTAINER Marcel Jira <marcel.jira@gmail.com>

ENV PYTHONUNBUFFERED 1

WORKDIR /app
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
    apt-get clean;
    
# make directory
VOLUME /app/djangocms-app
RUN mkdir /var/www && \
    chown -R www-data:www-data djangocms-app && \
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

ENV VIRTUAL_ENV=/app/djangocms-app
RUN python3 -m venv $VIRTUAL_ENV --system-site-packages
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Finally, start the server
EXPOSE $internal_port
# STOPSIGNAL SIGTERM

VOLUME $VIRTUAL_ENV

CMD python3 scripts/runscript.py
