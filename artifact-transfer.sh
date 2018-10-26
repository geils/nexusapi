#!/bin/bash

##########################################################
### Artifacts Download and Upload Script for Nexus OSS ###
##########################################################
#
#  To Download : 
#    curl -O -X GET -u "admin:password" "http://<nexus>/repository/<repo>/com/sktechx/ims/ims-client/1.0/ims-client-1.0.jar"
#
#  To Upload :
#    curl -v -u admin:admin123 --upload-file pom.xml http://localhost:8081/repository/maven-releases/org/foo/1.0/foo-1.0.pom
#
#
#
#
#  Command full example : 
#    ~$ ./artifact-transfer.sh team-pfdev2-releases 
#
#############################
# DEFINE SERVER INFO
#############################
TARGETSVR=http://192.168.56.101:8081 #wnd2http://nexus.skplanet.com
SOURCESVR=http://nexus.skplanet.com #http://mvn.skplanet.com
repoName=$1


#################################
# GET ARTIFACT PATH TO DOWNLOAD
#################################

curl -u "admin:parch2017%!" -X GET http://$SOURCESVR/service/rest/v1/search?repository=$repoName | jq --raw-output '.items[].assets[].path' > artipath-list.txt

IFS=$'\r\n' GLOBIGNORE='*' command eval 'XYZ=($(cat skp-nexus-repolist.txt))'




##################
# LOCAL TESTING
##################
while read line
do
    curl -O -X GET -u "admin:parch2017%!" http://$TARGETSVR/repository/$repoName/$ARTIPATH

done < artipath-list.txt

function artifact_up {
    curl -v -u admin:admin123 --upload-file $artifactNAME $artifactURL
}


function artifact_dn {

}

declare -a gindex

let i=0
while 








GROUPLIST=$1

### CHECK ARTIFACT LIST FILE EXIST

#curl -u admin:admin123 -X GET 'http://192.168.56.101:8081/service/rest/v1/search?repository=pfdev2' | jq --raw-output '.items[].group' | uniq > get-group.txt

while read line
do
    ### now ${line} is group name
    mkdir ${line}
    echo -e "READ $GROUPLIST FILE"

    if [ -f ${line}-package.txt ]; then
        :
    else
        curl -u admin:admin123 -X GET 'http://192.168.56.101:8081/service/rest/v1/search?repository=pfdev2&group='${line} | jq --raw-output '.items[].name' | uniq > ./${line}/${line}-package.txt
    fi

    cd ${line}  #### now script path/group/.
    PACKLIST=`realpath *-package.txt`
    GROUPNAME=${line}

    ########################### PACKAGE LOOP
    while read line
    do
        ### now ${line} is package name
        mkdir ${line}
        echo -e "READ $PACKLIST FILE"
        curl -u admin:admin123 -X GET 'http://192.168.56.101:8081/service/rest/v1/search?repository=pfdev2&group='$GROUPNAME | jq --raw-output '.items[].version' | uniq > ./${line}/${line}-version.txt
        

    done < $PACKLIST    


done < $GROUPLIST

echo -e "PACKAGES LIST CREATION DONE."
