#!/bin/bash
routetype=$1

cp -rv lualib $routetype
cp -rv luaspecifics $routetype
cp -v $routetype.lua $routetype
cp -rv ~/osrm-backend/profiles/lib $routetype/
cp -v ~/osrm-backend/build/osrm-* $routetype
