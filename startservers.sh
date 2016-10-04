#!/bin/bash
set -ex

cd /50g/osrmbuilder/auk
nohup ./osrm-routed -p 5001 countries.osrm>run.log 2>&1 &

cd /50g/osrmbuilder/touristb
nohup ./osrm-routed -p 5002 countries.osrm>run.log 2>&1 &
