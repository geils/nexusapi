#!/bin/bash

SSVR="source.nexusserver.com"
REPONAME="reponame"


CONTOKEN=`curl -v -X GET "http://$SSVR/service/rest/v1/search?repository=$REPONAME" | jq --raw-output '.continuationToken'`
curl -v -X GET "http://$SSVR/service/rest/v1/search?repository=$REPONAME" | jq --raw-output '.items[].group' | uniq > get-groups.txt

while [[ $CONTOKEN != "null" ]]
do
    curl -v -X GET "http://$SSVR/service/rest/v1/search?repository=$REPONAME&continuationToken=$CONTOKEN" | jq --raw-output '.items[].group' | uniq >> get-groups.txt
    CONTOKEN=`curl -v -X GET "http://$SSVR/service/rest/v1/search?repository=$REPONAME&continuationToken=$CONTOKEN" | jq --raw-output '.continuationToken'`
done
