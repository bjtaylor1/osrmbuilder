#/bin/bash

set -e
echo $1

if [ ! -f "$1" ]; then
  echo "File not found"
  exit 1
fi

for c in changesets/*.xml; do
  osmosis --read-xml-change "$c" --sort-change --read-pbf "$1" --apply-change --write-pbf "$1.new"
  mv "$1.new" "$1"
done


