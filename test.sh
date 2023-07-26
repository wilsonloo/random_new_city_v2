#!/bin/bash

newdir=""
k=1
while [ $k -lt 1000 ]
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

if [ "$newdir" == "" ]
then
    echo "too many outputs"
    exit 1
fi

lua ./test.lua $newdir
cd tools/imggenerater && python3 generate.py ../../$newdir