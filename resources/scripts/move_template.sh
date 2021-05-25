#!/bin/sh
mv -u /template/* /app/
chown -R www-data:www-data /app
chmod -R 775 /app
chmod -R g+s /app
