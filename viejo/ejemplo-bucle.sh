#!/bin/sh
ARRAY1=$(cat list)
for i in ${ARRAY1}; do 
  # curl --user ${REG_USER} http://${REGISTRY}/v2/$i/tags/list | grep null ;
  echo $i;
done

