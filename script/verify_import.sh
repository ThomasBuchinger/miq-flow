#!/bin/bash
DOMAIN=${DOMAIN-feat_f1_buc}
SUITE=${SUITE-default}

RESPONSE=$(curl -k --user admin:smartvm "https://localhost:8443/api/automate/${DOMAIN}?depth=-1&attributes=klass,domain_fnname")

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
