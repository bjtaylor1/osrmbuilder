#/!bin/bash

set -e

#download urbanness data from the government!
mkdir urbannessdata
cd urbannessdata
../downloadurbannessdata.sh
for z in *.zip; do unzip $z; done
../importurbannessdata.sh
