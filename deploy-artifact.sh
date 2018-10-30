#!/bin/bash

# $1 = repository directory
# $2 = pathlist file location

IFS=$'\r\n' GLOBIGNORE='*' command eval 'pathlist=($(cat $2))'
IFS=$'\r\n' GLOBIGNORE='*' command eval 'arrlist=($(ls $1 | sort))'

cd $1
#echo "${arrlist[0]}"
#echo "${pathlist[1]}"
#echo -e ${pathlist[0]}
#echo -e ${pathlist[$(($i))]}

i=0
set -ex

for item in ${arrlist[*]}
do
    if [[ $item == ${pathlist[$(($i))]##*/} ]]; then
        echo -e "### TARGET FILE AND PATHFILE IS MATCHED ! ###"
        curl -v -u "admin:parch2017%!" --upload-file $item http://nexus.skplanet.com/repository/skp-releases/${pathlist[$(($i))]}
        i=$(expr $i + 1)
    else
       echo -e "### [ERROR] FILE NOT MATCHED ! PLEASE CHECK FILE LIST ###"
       exit 0
    fi
done
