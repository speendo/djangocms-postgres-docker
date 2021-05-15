#!/app/bin/python3
import os
import subprocess

import time
import sys
import psycopg2

# read variables
VIRTUAL_ENV = os.environ['VIRTUAL_ENV']

project_dir = os.environ['project_dir']
project_name = os.environ['project_name']

internal_port = os.environ['internal_port']

init_postgres_host = os.environ['init_postgres_host']
POSTGRES_DB = os.environ['POSTGRES_DB']
POSTGRES_USER = os.environ['POSTGRES_USER']
POSTGRES_PASSWORD = os.environ['POSTGRES_PASSWORD']
init_db_port = os.environ['init_db_port']

POSTGRES_DB_FILE = os.environ['POSTGRES_DB_FILE']
POSTGRES_USER_FILE = os.environ['POSTGRES_USER_FILE']
POSTGRES_PASSWORD_FILE = os.environ['POSTGRES_PASSWORD_FILE']

db_in_file = os.path.isfile(POSTGRES_DB_FILE) and os.stat(POSTGRES_DB_FILE).st_size != 0
db_user_in_file = os.path.isfile(POSTGRES_USER_FILE) and os.stat(POSTGRES_USER_FILE).st_size != 0
db_password_in_file = os.path.isfile(POSTGRES_PASSWORD_FILE) and os.stat(POSTGRES_PASSWORD_FILE).st_size != 0

init_db = POSTGRES_DB

if db_in_file:
	print("database name in secret file")
	f = open(POSTGRES_DB_FILE)
	init_db = f.readline().strip()
else:
	print("database name from env variable")

init_db_user = POSTGRES_USER
if db_user_in_file:
	print("database user in secret file")
	f = open(POSTGRES_USER_FILE)
	init_db_user = f.readline().strip()
else:
	print("database user from env variable")

init_db_password = POSTGRES_PASSWORD
if db_password_in_file:
	print("database password in secret file")
	f = open(POSTGRES_PASSWORD_FILE)
	init_db_password = f.readline().strip()
else:
	print("database password from env variable (unsecure)")

init_database = f"postgres://{init_db_user}:{init_db_password}@{init_postgres_host}:{init_db_port}/{init_db}"

init_i18n = os.environ['init_i18n']
init_use_tz = os.environ['init_use_tz']
init_timezone = os.environ['init_timezone']
init_permissions = os.environ['init_permissions']
init_languages = os.environ['init_languages']
init_bootstrap = os.environ['init_bootstrap']
init_starting_page = os.environ['init_starting_page']
use_gunicorn = os.environ['use_gunicorn']
gunicorn_number_of_workers = os.environ['gunicorn_number_of_workers']

init_i18n = "no" if init_i18n == "no" else "yes"
init_use_tz = "no" if init_use_tz == "no" else "yes"
init_permissions = "yes" if init_permissions == "yes" else "no"
init_bootstrap = "yes" if init_bootstrap == "yes" else "no"
init_starting_page = "yes" if init_starting_page == "yes" else "no"

# setup djangocms call
django_cms_call = ["djangocms"] # base command
django_cms_call += ["--db", init_database] # add database
django_cms_call += ["--no-deps"] # don't install package dependencies
django_cms_call += ["--i18n", init_i18n] # add i18n
django_cms_call += ["--use-tz", init_use_tz] # activate timezone-support
if init_timezone != "":
	django_cms_call += ["--timezone", init_timezone] # add timezone if specified
django_cms_call += ["--permissions", init_permissions] # add permissions
for lang in init_languages.split():
	django_cms_call += ["--languages", lang] # add languages
django_cms_call += ["--bootstrap", init_bootstrap] # add bootstrap
django_cms_call += ["--starting-page", init_starting_page] # add starting page
django_cms_call += ["--parent-dir", project_dir] # add parent_dir
django_cms_call += [project_name] # add project name

# test database connection

db_ready = None
db_connect_attempts = 0
while db_ready == None:
	db_connect_attempts += 1
	try:
		db_ready = psycopg2.connect(dbname=init_db, user=init_db_user, host=init_postgres_host, port=init_db_port, password=init_db_password)
	except:
		print(f"Failed to connect to database (tried {db_connect_attempts} of 300 times).")
		if db_connect_attempts < 300:
			print("Retrying in 3 seconds.")
			time.sleep(3)
		else:
			print("Giving up.")
			sys.exit(1)
print("Database is ready")
db_ready.close()			

# check if project was already created
project_not_present = not os.path.isfile(f"{project_dir}/manage.py")

if project_not_present:
	print("Initialising project")
	subprocess.run(django_cms_call, check=True)
else:
	print("Accessing existing project")

# migrate (do this at each start to make sure any changes in settings.py are caught and start django and gunicorn
subprocess.run([f"{VIRTUAL_ENV}/bin/python3", f"{project_dir}/manage.py", "makemigrations"], check=True)
subprocess.run([f"{VIRTUAL_ENV}/bin/python3", f"{project_dir}/manage.py", "migrate"], check=True)

if use_gunicorn.lower() == "yes":
	print("Serving with gunicorn")
	# collect static files in order to serve them with gunicorn
	subprocess.run([f"{VIRTUAL_ENV}/bin/python3", f"{project_dir}/manage.py", "collectstatic", "--noinput", "--link"], check=True)

	# this should run forever
	os.system(f"su --shell /bin/sh www-data -c \"{VIRTUAL_ENV}/bin/gunicorn --chdir {project_dir}/ {project_name}.wsgi -b 0.0.0.0:{internal_port} --workers={gunicorn_number_of_workers}\"")
else:
	print("serving with django's \"manage.py\"")
	os.system(f"su --shell /bin/sh www-data -c \"{project_dir}/manage.py runserver {internal_port}\"")
