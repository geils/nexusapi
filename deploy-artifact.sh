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
set -x

for item in ${arrlist[*]}
do
    curl -v --upload-file $item http://nexus.company.com/repository/3rd-party/${pathlist[$(($i))]}
    i=$(expr $i + 1)      
done
