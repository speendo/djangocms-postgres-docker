#!/usr/bin/python3
import os

# read variables
internal_port = os.environ['internal_port']
init_database = os.environ['init_database']
init_i18n = os.environ['init_i18n']
init_use_tz = os.environ['init_use_tz']
init_timezone = os.environ['init_timezone']
init_permissions = os.environ['init_permissions']
init_languages = os.environ['init_languages']
init_bootstrap = os.environ['init_bootstrap']
init_starting_page = os.environ['init_starting_page']
use_gunicorn = os.environ['use_gunicorn']
gunicorn_number_of_workers = os.environ['gunicorn_number_of_workers']

init_languages = init_languages.replace(" ", " -l ")
init_languages = " -l " + init_languages if init_languages != "" else ""

init_timezone = "--timezone " + init_timezone if init_timezone != "" else ""

init_i18n = "no" if init_i18n == "no" else "yes"
init_use_tz = "no" if init_use_tz == "no" else "yes"
init_permissions = "yes" if init_permissions == "yes" else "no"
init_bootstrap = "yes" if init_bootstrap == "yes" else "no"
init_starting_page = "yes" if init_starting_page == "yes" else "no"

# check if manage.py was already created
firstrun = not os.path.isfile("djangocms/manage.py")

if firstrun:
	os.system(f"djangocms --db {init_database} -n --i18n {init_i18n} --use-tz {init_use_tz} {init_timezone} --permissions {init_permissions}{init_languages} --bootstrap {init_bootstrap} --starting-page {init_starting_page} -p /app/djangocms djangocms")
else:
	pass

# migrate (do this at each start to make sure any changes in settings.py are caught and start django and gunicorn
os.system("/app/djangocms/manage.py makemigrations; /app/djangocms/manage.py migrate")

if use_gunicorn.lower() == "yes":
	# collect static files in order to serve them with gunicorn
	os.system("/app/djangocms/manage.py collectstatic --noinput --link")

	# this should run forever
	os.system(f"su - www-data -c \"gunicorn --chdir /app/djangocms/ djangocms.wsgi -b 0.0.0.0:{internal_port} --workers={gunicorn_number_of_workers}\"")
else:
	os.system(f"/app/djangocms/manage.py runserver {internal_port}")
