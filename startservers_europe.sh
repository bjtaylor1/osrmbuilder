#!/bin/bash
set -ex

nohup shortest/osrm-routed -p 5001 shortest/countries.osrm>/dev/null 2>&1 &
