#!/bin/bash
DOMAIN=${DOMAIN-feature_f1_buc}
SUITE=${SUITE-default}
if [[ $SUITE != "integration" ]]; then exit 0; fi

bundle exec ./bin/cli.rb devel1 
echo "===================================================================================="
bundle exec ./bin/cli.rb list
echo "===================================================================================="
bundle exec ./bin/cli.rb inspect feature-1-f1
echo "===================================================================================="
bundle exec ./bin/cli.rb deploy feature-1-f1 --provider docker
echo "===================================================================================="


echo "=== Docker PS ======================================================================"
docker ps
echo "===================================================================================="
RESPONSE=$(curl -k --user admin:smartvm "https://localhost:8443/api/automate/${DOMAIN}?depth=-1&attributes=klass,domain_fnname")
echo "==== Response ======================================================================"
echo $RESPONSE
echo "===================================================================================="


ERROR=$(echo $RESPONSE | ruby -rjson -e "puts JSON.load(STDIN).dig('error', 'kind')")
if [[ $ERROR == "bad_request" ]]; then
  echo "ERROR: ManageIQ Error: $ERROR"
  exit 10
fi
COUNT=$(echo $RESPONSE | ruby -rjson -e "puts JSON.load(STDIN).dig('subcount')" )
if [[ $COUNT -gt 0 ]]; then
  exit 0
else
  exit 1
fi  
