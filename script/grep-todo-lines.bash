#!/bin/bash
# grep project files for non-completed lines matching the provided pattern

prog=$(basename "$0")
progdir=$(dirname "$0")

indent=
skip=
for fn in $(rg --files --glob '*.wofl'); do
  cat "$fn" | "$progdir/delete-completed-lines.bash" | rg --with-filename --line-number --no-heading --color=always --no-trim "$@" | sed "s/<stdin>/$fn/"
done
