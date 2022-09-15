#!/bin/bash

# for ech folder in current directory update maven version
# Usage: updateVersion.sh 1.0.0

# check if version is passed
if [ -z "$1" ]
  then
    echo "No version supplied"
    exit 1
fi

SUCCESS_URL="https://jenkins.ivyteam.io/job/core_product/job/master/lastSuccessfulBuild"
JSON=$(curl -s "$SUCCESS_URL/api/json?pretty=true")
ARTIFACT_PATTERN=AxonIvyEngine[0-9\.]*_All_x64.zip
REL_PATH=$(echo $JSON | \
  grep -o '"relativePath" : "[^"]*"' | \
  grep -o "[^\"]*${ARTIFACT_PATTERN}")
ZIP=$(basename "$REL_PATH")
REVISION=$(echo $ZIP | grep -o -E '[0-9]{10}')
echo "found revision $REVISION"
DL_URL=$SUCCESS_URL/artifact/$REL_PATH

if [ -x "$(command -v wget )" ]; then
  wget "$DL_URL" -P /tmp
elif [ -x "$(command -v curl )" ]; then
  curl "$DL_URL" -o "/tmp/$ZIP"
fi

# loop through all folders
for d in */ ; do
  echo "Updating $d"
  cd $d
  mvn -B versions:set -DnewVersion=$1 -DgenerateBackupPoms=false -DprocessAllModules=true
  cd ..
done
