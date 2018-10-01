#!/bin/bash
set -ex

nohup shortest/osrm-routed -p 5001 shortest/countries.osrm>/dev/null 2>&1 &
nohup optimum/osrm-routed -p 5002 optimum/countries.osrm>/dev/null 2>&1 &
nohup quickest/osrm-routed -p 5003 quickest/countries.osrm>/dev/null 2>&1 &
nohup urban/osrm-routed -p 5004 urban/countries.osrm>/dev/null 2>&1 &
