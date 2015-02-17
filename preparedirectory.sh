#!/bin/bash
routetype=$1

cp -rv lualib $routetype
cp -rv luaspecifics $routetype
cp -v $routetype.lua $routetype
cp -v ../Project-OSRM/build/osrm-* $routetype
