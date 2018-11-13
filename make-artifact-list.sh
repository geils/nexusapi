#!/bin/bash

# $1 = repository
# $2 = group // temporary as $1

SSVR="source.nexusserver.com"
REPO=$1
GROUPID=$2
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
IDPASS="id:pass"

onepass_dn () {

    set -ex
    ### MAKE DIRECTORY
    mkdir $REPO-$GROUPID
    
    ### READY TO ARTIFACT DOWNLOAD / MAKE DOWNLOADURL LIST FILE
    curl -u $IDPASS -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$GROUPID" | jq --raw-output '.items[].assets[].downloadUrl' | sort > downloadUrl.txt

    ### LIST SORT
    sort downloadUrl.txt > downloadUrl-s.txt

    ### DOWNLOAD ARTIFACTS
    ./get-artifact.sh $REPO-$GROUPID downloadUrl-s.txt

    ### GET SORTED ARTIFACT PATHLIST FOR UPLOAD
    curl -u $IDPASS -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$GROUPID" | jq --raw-output '.items[].assets[].path' | sort > pathlist.txt

    ### LIST SORT
    sort pathlist.txt > pathlist-s.txt

    ### DEPLOY ARTIFACTS TO TARGET SERVER
    ./deploy-artifact.sh $REPO $REPO-$GROUPID pathlist-s.txt

    ### REMOVE TEXT FILES
    rm *.txt

    ### REMOVE COMPLETED ARTIFACTS DIRECTORY
    rm -rf $REPO-$GROUPID

    echo -e "${GREEN}### PROCESS COMPLETED ###${NC}"

}

pageread_dn () {

    set -ex
    ### MAKE DIRECTORY
    mkdir $REPO-$GROUPID
        
    ### READY TO ARTIFACT DOWNLOAD / MAKE DOWNLOADURL LIST FILE / PAGINATION
    CONTOKEN=`curl -u $IDPASS -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$GROUPID" | jq --raw-output '.continuationToken'`
    curl -u $IDPASS -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$GROUPID" | jq --raw-output '.items[].assets[].downloadUrl' > downloadUrl.txt

    while [[ $CONTOKEN != "null" ]]
    do
        curl -u $IDPASS -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$GROUPID&continuationToken=$CONTOKEN" | jq --raw-output '.items[].assets[].downloadUrl' >> downloadUrl.txt
        CONTOKEN=`curl -u $IDPASS -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$GROUPID&continuationToken=$CONTOKEN" | jq --raw-output '.continuationToken'`
        echo -e "${RED}$CONTOKEN${NC}"
    done

    ### LIST SORT
    sort downloadUrl.txt > downloadUrl-s.txt

    ### DOWNLOAD ARTIFACTS
    ./get-artifact.sh $REPO-$GROUPID downloadUrl-s.txt

    ### GET SORTED ARTIFACT PATHLIST FOR UPLOAD
    CONTOKEN=`curl -u $IDPASS -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$GROUPID" | jq --raw-output '.continuationToken'`
    curl -u $IDPASS -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$GROUPID" | jq --raw-output '.items[].assets[].path' > pathlist.txt

    while [[ $CONTOKEN != "null" ]]
    do
        curl -u $IDPASS -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$GROUPID&continuationToken=$CONTOKEN" | jq --raw-output '.items[].assets[].path' >> pathlist.txt
        CONTOKEN=`curl -u $IDPASS -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$GROUPID&continuationToken=$CONTOKEN" | jq --raw-output '.continuationToken'`
        echo -e "${RED}$CONTOKEN${NC}"
    done
    
    ### LIST SORT
    sort pathlist.txt > pathlist-s.txt

    ### DEPLOY ARTIFACTS TO TARGET SERVER
    ./deploy-artifact.sh $REPO $REPO-$GROUPID pathlist-s.txt

    ### REMOVE TEXT FILES
    rm *.txt

    ### REMOVE COMPLETED ARTIFACTS DIRECTORY
    rm -rf $REPO-$GROUPID
  

    echo -e "${GREEN}### PROCESS COMPLETED ###${NC}"
  
}


CHKCON=`curl -u $IDPASS -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$GROUPID" | jq --raw-output '.continuationToken'`
echo -e "${RED}$CHKCON${NC}"

if [ $CHKCON == "null" ]; then
    echo -e "##### GET ALLOF CONTENTS. KEEP GOING."
    onepass_dn $GROUPID
else
    echo -e "##### REMAIN PAGE IS EXISTS. WILL GET NEXT PAGE INFO."
    pageread_dn $GROUPID   
fi
