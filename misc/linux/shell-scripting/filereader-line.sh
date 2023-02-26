#!/bin/bash
input="/path/to/txt/file"
while IFS= read -r line
do
  echo "$line"
done < "$input"