#!/bin/bash

DIRNAME=$1
ARRLIST="../$2"

cd $1

while read line
do
    curl -O -X GET "$line"

done < $ARRLIST

cd ../
