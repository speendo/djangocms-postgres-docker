#!/bin/sh
# check if template folder is empty - skip the rest otherwise
if [ -n "$(ls -A -- ${template_env})" ]; then
	echo "Setup template"
	
	# check if venv is present
	if [ ! -f "${VIRTUAL_ENV}/bin/activate" ]; then
		echo "venv not present - move template folder to /app"
		sudo /scripts/move_template.sh
		
		# create venv
		echo "Create venv"
		python3 -m venv ${VIRTUAL_ENV} --system-site-packages
		echo "When logged into the container (e.g. with \"docker exec -it <container-name> /bin/bash\") venv can be activated with \"source ${VIRTUAL_ENV}/bin/activate\""

		echo "Upgrade pip"
		${VIRTUAL_ENV}/bin/python3 -m pip install --upgrade pip
		
		# install dependencies
		echo "Install DjangoCMS and other requirements"
		${VIRTUAL_ENV}/bin/pip3 --no-cache-dir install -r ${VIRTUAL_ENV}/req/initialrequirements.txt
		${VIRTUAL_ENV}/bin/pip3 --no-cache-dir install -r ${VIRTUAL_ENV}/req/djangocmsrequirements.txt
	fi
	
	# check if project folder is present
	if [ ! -d "${project_dir}" ]; then
		echo "project folder not present - move project folder from template"
		mv -u ${template_project_dir} ${project_dir}
	fi
	
	# install other requirements specified by the user
	echo "Install additionally specified Debian packages from ${VIRTUAL_ENV}/req/user_debianpackages.txt"
	sudo /scripts/install_user_debian_packages.sh
	echo "Install additionally specified Python packages from ${VIRTUAL_ENV}/req/user_pythonpackages.txt"
	${VIRTUAL_ENV}/bin/pip3 --no-cache-dir install -r ${VIRTUAL_ENV}/req/user_pythonpackages.txt
else
	echo "Template not present - assuming that setup was done before"
fi

# Start DjangoCMS
echo "Start DjangoCMS"
${VIRTUAL_ENV}/bin/python3 /scripts/runscript.py
