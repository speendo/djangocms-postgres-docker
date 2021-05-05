# djangocms-postgres-docker
Simple Docker Image to create a DjangoCMS instance with a PostgreSQL data base

# sample docker-compose.yml

    version: '3'

    services:
      db:
        container_name: djangocms-db
        image: postgres
        restart: unless-stopped
        env_file:
          - env/postgres.env
        volumes:
          - ./djangodb:/var/lib/postgresql/data
        secrets:
          - postgres_db
          - postgres_user
          - postgres_password
        networks:
          - djangocms

      app:
        container_name: djangocms-app
        image: speendo/djangocms-postgresql:latest
        restart: unless-stopped
        env_file:
          - env/postgres.env
          - env/djangocms.env
        volumes:
          - ./djangocms:/app/djangocms
        ports:
          - 9090:9090
        depends_on:
          - db
        secrets:
          - postgres_db
          - postgres_user
          - postgres_password
        networks:
          - djangocms

    secrets:
      postgres_db:
        file: secrets/postgres_db.txt
      postgres_user:
        file: secrets/postgres_user.txt
      postgres_password:
        file: secrets/postgres_password.txt

    networks:
      djangocms:
