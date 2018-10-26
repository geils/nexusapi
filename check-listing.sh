#!/bin/bash

set -x
# fixed repo : thirdparty

#curl -X GET "http://172.19.107.18:8081/service/rest/v1/search?repository=thirdparty&group=$1"

SSVR="172.19.107.18"
REPO="thirdparty"


    CONTOKEN=`curl -X GET "http://$SSVR:8081/service/rest/v1/search?repository=$REPO&group=$1" | jq --raw-output '.continuationToken'`
    curl -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$1" | jq --raw-output '.items[].assets[].downloadUrl' > downloadUrl.txt

    while [[ $CONTOKEN != "null" ]]
    do
        curl -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$1&continuationToken=$CONTOKEN" | jq --raw-output '.items[].assets[].downloadUrl' >> downloadUrl.txt
        CONTOKEN=`curl -X GET "http://$SSVR:8081/service/rest/v1/search?repository=$REPO&group=$1&continuationToken=$CONTOKEN" | jq --raw-output '.continuationToken'`
    done
