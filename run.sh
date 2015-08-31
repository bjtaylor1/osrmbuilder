#!/bin/bash
set -e

#refresh the data
./refresh.sh

#merge britain and france together
./combine.sh

#build osrm
./buildosrm.sh

#create a directory for each one, copies all the lua etc into it
./preparedirectories.sh


