#!/bin/bash
filename=$1
# echo "Enter file name to cat / head or tail"

echo "Do you want to cat or head or tail this file?"
read ops
[[  -f $filename ]] &&  $ops $filename 
