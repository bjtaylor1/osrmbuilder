#!/bin/bash
set -e

./refreshandmergeallsourcedata.sh

#build osrm
./buildosrm.sh

#create a directory for each one, copies all the lua etc into it
./preparedirectories.sh


