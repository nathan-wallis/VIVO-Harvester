#!/bin/bash

#Copyright (c) 2010-2011 VIVO Harvester Team. For full list of contributors, please see the AUTHORS file provided.
#All rights reserved.
#This program and the accompanying materials are made available under the terms of the new BSD license which accompanies this distribution, and is available at http://www.opensource.org/licenses/bsd-license.html

#Directory where harvester has been built
HARVESTER_INSTALL_DIR=/home/nathanwallis/Desktop/vivo_harvester_github
export HARVEST_NAME=example-jdbc
export DATE=`date +%Y-%m-%d'T'%T`

#	included within the classpath and the path environment variables.
export PATH=$PATH:$HARVESTER_INSTALL_DIR/bin
#export CLASSPATH=$CLASSPATH:$HARVESTER_INSTALL_DIR/bin/harvester.jar:$HARVESTER_INSTALL_DIR/bin/dependency/*
export CLASSPATH=$CLASSPATH:$HARVESTER_INSTALL_DIR/build/harvester.jar:$HARVESTER_INSTALL_DIR/build/dependency/*
echo $CLASSPATH;

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

# clone db
harvester-databaseclone -X databaseclone.config.xml

# Execute Fetch
harvester-jdbcfetch -X jdbcfetch.config.xml

# Execute Translate
# This is the part of the script where the input data is transformed into valid RDF
#   Translate will apply an xslt file to the fetched data which will result in the data 
#   becoming valid RDF in the VIVO ontology
harvester-xsltranslator -X xsltranslator.config.xml

# Execute Transfer to import from record handler into local temp model
#	data storage structure similar to a database, but in RDF.
# The harvester tool Transfer is used to move/add/remove/dump data in models.
# For this call on the transfer tool:
# -s refers to the source translated records file, which was just produced by the translator step
# -o refers to the destination model for harvested data
# -d means that this call will also produce a text dump file in the specified location 
harvester-transfer -s translated-records.config.xml -o harvested-data.model.xml -d data/harvested-data/imported-records.rdf.xml

# Execute Score
# In the scoring phase the data in the harvest is compared to the data within Vivo and a new model
# 	is created with the values / scores of the data comparsions. 

# Execute Score for People
harvester-score -X score-people.config.xml

# Find matches using scores and rename nodes to matching uri
# Using the data model created by the score phase, the match process changes the harvested uris for
# 	comparsion values above the chosen threshold within the xml configuration file.
# Execute Match for People and Departments
#harvester-match -X match-people-departments.config.xml

#Truncate Score Data model
# Since we are finished with the scoring data for people and departments,
#   we need to clear out all that old data before we add more
#harvester-jenaconnect -j score-data.model.xml -t

# Execute Score for Positions
#harvester-score -X score-positions.config.xml

# Execute Match for Positions
#harvester-match -X match-positions.config.xml

# Execute ChangeNamespace to get unmatched  into current namespace
# This is where the new people, departments, and positions from the harvest are given uris within the namespace of Vivo
# 	If there is an issue with uris being in another namespace, this is the phase
#	which should give some light to the problem.
# Execute ChangeNamespace for People
harvester-changenamespace -X changenamespace-people.config.xml

# Execute ChangeNamespace for Departments
#harvester-changenamespace -X changenamespace-departments.config.xml

# Execute ChangeNamespace for Positions
#harvester-changenamespace -X changenamespace-positions.config.xml

# Perform an update
# The harvester maintains copies of previous harvests in order to perform the same harvest twice
#   but only add the new statements, while removing the old statements that are no longer
#   contained in the input data. This is done in several steps of finding the old statements,
#   then the new statements, and then applying them to the Vivo main model.

# Find Subtractions
# When making the previous harvest model agree with the current harvest, the statements that exist in
#	the previous harvest but not in the current harvest need to be identified for removal.
harvester-diff -X diff-subtractions.config.xml

# Find Additions
# When making the previous harvest model agree with the current harvest, the statements that exist in
#	the current harvest but not in the previous harvest need to be identified for addition.
harvester-diff -X diff-additions.config.xml

# Apply Subtractions to Previous model
harvester-transfer -o previous-harvest.model.xml -r data/vivo-subtractions.rdf.xml -m
# Apply Additions to Previous model
harvester-transfer -o previous-harvest.model.xml -r data/vivo-additions.rdf.xml

# Now that the changes have been applied to the previous harvest and the harvested data in vivo
#	agree with the previous harvest, the changes are now applied to the vivo model.
# Apply Subtractions to VIVO for pre-1.2 versions
harvester-transfer -o vivo.model.xml -r data/vivo-subtractions.rdf.xml -m
# Apply Additions to VIVO for pre-1.2 versions
harvester-transfer -o vivo.model.xml -r data/vivo-additions.rdf.xml

#Output some counts
ORGS=`cat data/vivo-additions.rdf.xml | grep 'http://xmlns.com/foaf/0.1/Organization' | wc -l`
PEOPLE=`cat data/vivo-additions.rdf.xml | grep 'http://xmlns.com/foaf/0.1/Person' | wc -l`
POSITIONS=`cat data/vivo-additions.rdf.xml | grep 'positionForPerson' | wc -l`
echo "Imported $ORGS organizations, $PEOPLE people, and $POSITIONS positions"

echo 'Harvest completed successfully'
