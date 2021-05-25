#!/bin/sh
# check if template is still there - skip the rest otherwise
if [ -d "${template_env}" ]; then
	echo "Setup template"
	
	# check if venv is present
	if [ ! -f "${VIRTUAL_ENV}/bin/activate" ]; then
		echo "venv not present - move template folder to /app"
		mv -u ${template_env}/* ${VIRTUAL_ENV}/
		
		echo "set permissions of ${VIRTUAL_ENV} to www-data"
		chown -R www-data:www-data ${VIRTUAL_ENV} && \
		chmod -R 775 ${VIRTUAL_ENV} && \
		chmod -R g+s ${VIRTUAL_ENV};

		# create venv
		echo "Create venv"
		su --shell /bin/sh www-data -c "python3 -m venv ${VIRTUAL_ENV} --system-site-packages"
		echo "When logged into the container (e.g. with \"docker exec -it <container-name> /bin/bash\") venv can be activated with \"source ${VIRTUAL_ENV}/bin/activate\""

		echo "Upgrade pip"
		su --shell /bin/sh www-data -c " ${VIRTUAL_ENV}/bin/python3 -m pip install --upgrade pip"
		
		# install dependencies
		echo "Install DjangoCMS and other requirements"
		su --shell /bin/sh www-data -c "${VIRTUAL_ENV}/bin/pip3 --no-cache-dir install -r ${VIRTUAL_ENV}/req/initialrequirements.txt"
		su --shell /bin/sh www-data -c "${VIRTUAL_ENV}/bin/pip3 --no-cache-dir install -r ${VIRTUAL_ENV}/req/djangocmsrequirements.txt"
	fi
	
	# check if project folder is present
	if [ ! -d "${project_dir}" ]; then
		echo "project folder not present - move project folder from template"
		su --shell /bin/sh www-data -c "mv -u ${template_project_dir} ${project_dir}"
	fi
	
	# finally, delete template folder
	echo "Delete template"
	rm -r ${template_env}
fi

# Start DjangoCMS
echo "Start DjangoCMS"
su --shell /bin/sh www-data -c "${VIRTUAL_ENV}/bin/python3 /scripts/runscript.py"
