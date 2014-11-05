#!/bin/bash

# see example-scripts/README.txt for information about HARVESTER_JAVA_OPTS

HARVESTER_INSTALL_DIR=/home/nathanwallis/Desktop/vivo_harvester_github
export HARVEST_NAME=example-jdbc
export DATE=`date +%Y-%m-%d'T'%T`

# Add harvester binaries to path for execution
# The tools within this script refer to binaries supplied within the harvester
#	Since they can be located in another directory their path should be
#	included within the classpath and the path environment variables.
export PATH=$PATH:$HARVESTER_INSTALL_DIR/bin
# export CLASSPATH=$CLASSPATH:$HARVESTER_INSTALL_DIR/bin/harvester.jar:$HARVESTER_INSTALL_DIR/bin/dependency/*
export CLASSPATH=$CLASSPATH:$HARVESTER_INSTALL_DIR/build/harvester.jar:$HARVESTER_INSTALL_DIR/build/dependency/*

# Exit on first error
set -e

# Supply the location of the detailed log file which is generated during the script and link to the latest
echo "Full Logging in $HARVEST_NAME.$DATE.log"
if [ ! -d logs ]; then
  mkdir logs
fi
cd logs
touch $HARVEST_NAME.$DATE.log
ln -sf $HARVEST_NAME.$DATE.log $HARVEST_NAME.latest.log
cd ..

#clear old data
rm -rf data

#fetch
java $HARVESTER_JAVA_OPTS org.vivoweb.harvester.fetch.OAIFetch -X oaifetch.conf.xml

#translate
harvester-xsltranslator -X xsltranslator.config.xml


