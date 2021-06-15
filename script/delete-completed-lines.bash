#!/bin/bash
# read stdin and blank-out any lines under a completed node

indent=
skip=
while IFS= read -r line; do
  if [[ $skip ]] && [[ $line =~ ^$indent([^*]|$) ]]; then
    echo
  elif [[ $line =~ ^([[:space:]]*)- ]]; then
    indent=${BASH_REMATCH[1]}
    echo
    skip=1
  else
    echo "$line"
    skip=
  fi
done
