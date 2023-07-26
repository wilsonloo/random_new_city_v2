#!/bin/bash

newdir=""
k=1
while [ $k -lt 10 ]
do
    subdir="./output/"$k
    if [ ! -d $subdir ]
    then
        newdir=$subdir
        mkdir -p $subdir
        break
    fi
    k=$(($k+1))
done

if [ "$newdir" != "" ]
then
    lua ./test.lua $newdir
fi