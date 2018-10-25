#!/bin/bash

ARTILIST=$1

while read line
do
    curl -O -X GET "$line"

done < $1
