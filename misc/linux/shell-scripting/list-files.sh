#!/bin/bash
filter=$1
echo "enter directory"
read dir
if [ -d $dir ]
then 
	ls $dir | sort | head | grep $1
else 
	echo "non dir location can not be traversed"
fi
