#!/bin/bash

# $1 = repository directory
# $2 = pathlist file location

IFS=$'\r\n' GLOBIGNORE='*' command eval 'pathlist=($(cat $2))'
#IFS=$'\r\n' GLOBIGNORE='*' command eval 'arrlist=($(ls $1 | sort))'
ls $1 | sort > dir.txt
REPONAME="skp-releases"
SSVR="nexus.skplanet.com"


cd $1
set -ex


while read line
do
    i=0
    for item in ${pathlist[*]}
    do  
        #echo $line
        #sleep 3
        #echo ${pathlist[$(($i))]##*/}
        if [[ $line == ${pathlist[$(($i))]##*/} ]]; then
            echo -e "### TARGET FILE AND PATHFILE LINE MATCHED ! ###"
            curl -v -u "admin:parch2017%!" --upload-file $line http://$SSVR/repository/$REPONAME/${pathlist[$(($i))]}
            break 1;
        else
            i=$(expr $i + 1 )
            :
        fi  
    done

done < ../dir.txt


#for item in ${arrlist[*]}
#do
#    if [[ $item == ${pathlist[$(($i))]##*/} ]]; then
#        echo -e "### TARGET FILE AND PATHFILE IS MATCHED ! ###"
#        curl -v -u "admin:parch2017%!" --upload-file $item http://$SSVR/repository/$REPONAME/${pathlist[$(($i))]}
#        i=$(expr $i + 1)
#    else
#       echo -e "### [ERROR] FILE NOT MATCHED ! PLEASE CHECK FILE LIST ###"
#       exit 0
#    fi
#done
