#!/usr/bin/python3
import os

# reat template_env
template_env = os.environ['template_env']

# check if template is still there - skip the rest otherwise
templatePresent = os.path.isdir(f"{template_env}")

if templatePresent:
	print("Setup template")

	#read other relevant env variables
	VIRTUAL_ENV = os.environ['VIRTUAL_ENV']

	template_project_dir = os.environ['template_project_dir']
	project_dir = os.environ['project_dir']

	# check if venv is present
	venvNotPresent = not os.path.isfile(f"{VIRTUAL_ENV}/bin/activate")

	if venvNotPresent:
		print("venv not present - move template folder to /app")
		os.system(f"mv -u {template_env}/* {VIRTUAL_ENV}/")
		
		# create venv
		print("Create venv")
		os.system(f"python3 -m venv {VIRTUAL_ENV} --system-site-packages")
		print(f"When logged into the container (e.g. with \"docker exec -it <container-name> /bin/bash\") venv can be activated with \"source {VIRTUAL_ENV}/bin/activate\"")

	# check if projects folder is present
	projectsNotPresent = not os.path.isdir(f"{project_dir}")

	if projectsNotPresent:
		print("project folder not present - move project folder from template")
		os.system(f"mv -u {template_project_dir} {project_dir}")
		

	# finally, delete template folder
	print("Delete template")
	os.system(f"rm -r {template_env}")
