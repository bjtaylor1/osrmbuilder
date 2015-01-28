#!/bin/bash

if [ "$1" == "r" ] ; then ec2din > instances.out; fi

index=1
grep "^INSTANCE" instances.out | while read line; do
	id=`echo $line | cut -f2 -d" "`
	url=`echo $line | cut -f4 -d" "`
	name=`grep "^TAG" instances.out | grep Name | grep "$id" | cut -f5`
  echo $index. $name
  echo $url>instances.$index.out
  index=$((index+1)) 
done
echo Enter number:
read num
url=`head -n1 instances.$num.out`

echo url=$url
ssh -i keypair.pem ubuntu@$url
