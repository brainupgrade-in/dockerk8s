#!/bin/bash
echo "enter directory"
read dir
if [ -d $dir ]
then 
	ls $dir | sort | head | grep 'top$'
else 
	echo "non dir location can not be traversed"
fi
