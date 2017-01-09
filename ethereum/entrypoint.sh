#!/bin/sh

instance_name=$(ip -4 -o a show | grep 172 | sed -e 's:\/.*::g' -e 's:.*inet ::')
sed -e "s:INSTANCE_CHANGEME:${instance_name}:" -i /app.json
pm2-docker start /app.json
