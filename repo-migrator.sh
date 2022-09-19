#!/bin/bash
#
# Usage: project-migrator.sh <version> <repository-name>
#

source ./project-migrator.sh

convert_to_version=$1
repo_name=$2
repos_url="https://github.com/axonivy-market/"


checkParams() {
  if [ -z "$convert_to_version" ]; then
    read -p "Please enter a version you want to convert to: " convert_to_version
  fi

  if [ -z "$repo_name" ]; then
    read -p "Please enter a repo name of ${repos_url} : " repo_name
  fi

  exists=$(curl -s -o /dev/null -w "%{http_code}" "${repos_url}${repo_name}")
  if [ $exists -ne 200 ]; then
    echo "Repo ${repos_url}${repo_name} does not exist"
    exit 1
  fi
}

cloneRepo() {
  if ! [ -d "${repo_name}" ]; then
    git clone "${repos_url}${repo_name}"
  fi
}

updateMavenVersion() {
  # update version in pom.xml
  # loop through all folders
  for d in */ ; do
    echo "Updating $d"
    mvn -f $d -B versions:set -DnewVersion=$convert_to_version -DgenerateBackupPoms=false -DprocessAllModules=true
  done

  # commit changes
  git add .
  git commit -m "Update maven version to $1"
}


checkParams
cloneRepo
downloadEngine

cd ${repo_name}
git switch -c "raise-to-${convert_to_version}"

raiseProject
updateMavenVersion
cd ..
