#!/bin/bash

#TEXTA="http://nexus.skplanet.com/repository/skp-3rd-party/com/skplanet/userinfra/spring/2.0.8/spring-2.0.8.pom.sha1"
#echo ${TEXTA##*/}

### $1 = file list
### $2 = path list (full path) / 1 file name($line) loop >> all pathfile lines

IFS=$'\r\n' GLOBIGNORE='*' command eval 'filelist=($(cat $1))'
PATHLIST=$2
i=0

while read line
do
    echo ${line##*/}
done < $PATHLIST



#for item in ${arrlist[*]}
#do
#    if [[ $item == ${pathlist[$(($i))]##*/} ]]; then
#        echo -e "### TARGET FILE AND PATHFILE IS MATCHED ! ###"
#        curl -v -u "admin:parch2017%!" --upload-file $item http://nexus.skplanet.com/repository/skp-releases/${pathlist[$(($i))]}
#        i=$(expr $i + 1)
#    else
#       echo -e "### [ERROR] FILE NOT MATCHED ! PLEASE CHECK FILE LIST ###"
#       exit 0
#    fi
#done
