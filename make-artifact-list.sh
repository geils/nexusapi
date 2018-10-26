#!/bin/bash

# $1 = repository
# $2 = group // temporary as $1

SSVR="172.19.107.18:8081"
REPO="thirdparty"
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'


onepass_dn () {

    set -x
    ### MAKE DIRECTORY
    mkdir $REPO-$1
    
    ### READY TO ARTIFACT DOWNLOAD / MAKE DOWNLOADURL LIST FILE
    curl -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$1" | jq --raw-output '.items[].assets[].downloadUrl' | sort > downloadUrl.txt

    ### DOWNLOAD ARTIFACTS
    ./get-artifact.sh $REPO-$1 downloadUrl.txt
    #(cd $1-$2 && ./get-artifact.sh downloadUrl.txt)

    ### MOVE ARTIFACTS TO GROUP DIRECTORY
    #mv *.json *.rpm *.gem *.tgz *.tar.gz *.zip *.pom *.jar *.sha1 *.md5 *.apklib ./$REPO-$1/

    ### GET SORTED ARTIFACT PATHLIST FOR UPLOAD
    curl -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$1" | jq --raw-output '.items[].assets[].path' | sort > pathlist.txt

    ### DEPLOY ARTIFACTS TO TARGET SERVER
    ./deploy-artifact.sh $REPO-$1 pathlist.txt

    ### REMOVE TEXT FILES
    rm *.txt

    ### REMOVE COMPLETED ARTIFACTS DIRECTORY
    rm -rf $REPO-$1

}

pageread_dn () {

    set -x
    ### MAKE DIRECTORY
    mkdir $REPO-$1
        
    ### READY TO ARTIFACT DOWNLOAD / MAKE DOWNLOADURL LIST FILE / PAGINATION
    CONTOKEN=`curl -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$1" | jq --raw-output '.continuationToken'`
    curl -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$1" | jq --raw-output '.items[].assets[].downloadUrl' > downloadUrl.txt

    while [[ $CONTOKEN != "null" ]]
    do
        curl -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$1&continuationToken=$CONTOKEN" | jq --raw-output '.items[].assets[].downloadUrl' >> downloadUrl.txt
        CONTOKEN=`curl -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$1&continuationToken=$CONTOKEN" | jq --raw-output '.continuationToken'`
        echo -e "${RED}$CONTOKEN${NC}"
    done

    ### LIST SORT
    sort downloadUrl.txt > downloadUrl-s.txt

    ### DOWNLOAD ARTIFACTS
    ./get-artifact.sh $REPO-$1 downloadUrl-s.txt
    #(cd $1-$2 && ./get-artifact.sh downloadUrl.txt)

    ### MOVE ARTIFACTS TO GROUP DIRECTORY
    #mv *.json *.rpm *.gem *.tgz *.tar.gz *.zip *.pom *.jar *.sha1 *.md5 *.apklib ./$REPO-$1/

    ### GET SORTED ARTIFACT PATHLIST FOR UPLOAD
    CONTOKEN=`curl -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$1" | jq --raw-output '.continuationToken'`
    curl -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$1" | jq --raw-output '.items[].assets[].path' > pathlist.txt

    while [[ $CONTOKEN != "null" ]]
    do
        curl -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$1&continuationToken=$CONTOKEN" | jq --raw-output '.items[].assets[].path' >> pathlist.txt
        CONTOKEN=`curl -X GET "http://$SSVR/service/rest/v1/search?repository=$REPO&group=$1&continuationToken=$CONTOKEN" | jq --raw-output '.continuationToken'`
        echo -e "${RED}$CONTOKEN${NC}"
    done
    
    ### LIST SORT
    sort pathlist.txt > pathlist-s.txt
    ### DEPLOY ARTIFACTS TO TARGET SERVER
    ./deploy-artifact.sh $REPO-$1 pathlist-s.txt

    ### REMOVE TEXT FILES
    rm *.txt

    ### REMOVE COMPLETED ARTIFACTS DIRECTORY
    rm -rf $REPO-$1
    
}


CHKCON=`curl -X GET "http://172.19.107.18:8081/service/rest/v1/search?repository=$REPO&group=$1" | jq --raw-output '.continuationToken'`
echo -e "${RED}$CHKCON${NC}"

if [ $CHKCON == "null" ]; then
    echo -e "##### GET ALLOF CONTENTS. KEEP GOING."
    onepass_dn $1
else
    echo -e "##### REMAIN PAGE IS EXISTS. WILL GET NEXT PAGE INFO."
    pageread_dn $1        
fi


echo -e "${GREEN}### PROCESS COMPLETED ###${NC}"
