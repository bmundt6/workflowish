#!/bin/bash
# read stdin and print the numbers of any lines under a completed node

indent=
skip=
linenr=0
while IFS= read -r line; do
  linenr=$(($linenr+1))
  if [[ $skip ]] && [[ $line =~ ^$indent([^*]|$) ]]; then
    echo $linenr
  elif [[ $line =~ ^([[:space:]]*)- ]]; then
    indent=${BASH_REMATCH[1]}
    echo $linenr
    skip=1
  else
    skip=
  fi
done
