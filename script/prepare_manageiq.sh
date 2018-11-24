#!/bin/bash
CONTAINER_NAME=${CONTAINER_NAME-manageiq}
TAG=${TAG-hammer-1-rc1}

docker rm -f $CONTAINER_NAME
docker pull manageiq/manageiq:$TAG

docker run --name $CONTAINER_NAME --privileged -d -p 8443:443 manageiq/manageiq:$TAG

sleep 180
for i in 1..20
do
  curl -k --user admin:smartvm -o /dev/null https://localhost:8443/api/servers/1
  CURL_RC=$?

  if [ $CURL_RC == 0 ]
  then
    STATUS=$(curl -k --user admin:smartvm https://localhost:8443/api/servers/1 | python -c 'import json,sys; print json.load(sys.stdin)["status"]')
    echo "ManageIQ started! Status: $STATUS"
    break
  else
    echo -n "."
    sleep 30
  fi
done
