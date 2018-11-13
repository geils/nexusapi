#!/bin/bash

# $1 = repository directory
# $2 = pathlist file location

IFS=$'\r\n' GLOBIGNORE='*' command eval 'pathlist=($(cat $3))'
ls $2 | sort > dir.txt

REPONAME=$1
SSVR="target.nexusserver.com"

YELLOW='\033[0;93m'
NC='\033[0m'

cd $2
set -e


while read line
do
    i=0
    for item in ${pathlist[*]}
    do  
        if [[ $line == ${pathlist[$(($i))]##*/} ]]; then
            echo -e "${YELLOW}### TARGET FILE AND PATHFILE LINE MATCHED ! ###${NC}"
            curl -v --upload-file "$line" "http://$SSVR/repository/$REPONAME/${pathlist[$(($i))]}"
            break 1;
        else
            i=$(expr $i + 1 )
            :
        fi  
    done

done < ../dir.txt
