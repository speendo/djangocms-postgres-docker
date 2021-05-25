#!/bin/sh
apt-get install -y --no-install-recommends $(grep -vE "^\s*#" /app/req/user_debianpackages.txt | sed -e 's/#.*//'  | tr "\n" " ")
