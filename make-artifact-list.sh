#!/bin/bash

# $1 = repository
# $2 = group

SSVR=172.19.107.18:8081

GETLIST=`curl -X GET "http://172.19.107.18:8081/service/rest/v1/search?repository=$1&group=$2" | jq --raw-output '.continuationToken'`
echo $GETLIST

if [ $GETLIST == "null" ]; then
    echo -e "##### GET ALLOF CONTENTS. KEEP GOING."
else
    echo -e "##### REMAIN PAGE IS EXISTS. STOP SCRIPT."
    exit 0 
fi

set -x
### MAKE DIRECTORY
mkdir $1-$2

### READY TO ARTIFACT DOWNLOAD / MAKE DOWNLOADURL LIST FILE
curl -X GET "http://$SSVR/service/rest/v1/search?repository=$1&group=$2" | jq --raw-output '.items[].assets[].downloadUrl' > downloadUrl.txt

### DOWNLOAD ARTIFACTS
cp get-artifact.sh downloadUrl.txt ./$1-$2/
(cd $1-$2 && ./get-artifact.sh downloadUrl.txt)

### MOVE ARTIFACTS TO GROUP DIRECTORY
#mv *.pom *.jar *.sha1 *.md5 *.apklib ./$1-$2/

### GET SORTED ARTIFACT PATHLIST FOR UPLOAD
curl -X GET "http://$SSVR/service/rest/v1/search?repository=$1&group=$2" | jq --raw-output '.items[].assets[].path' | sort > pathlist.txt

### DEPLOY ARTIFACTS TO TARGET SERVER
./deploy-artifact.sh $1-$2 pathlist.txt

### REMOVE TEXT FILES
rm *.txt

### REMOVE COMPLETED ARTIFACTS DIRECTORY
rm -rf $1-$2
