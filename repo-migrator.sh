#!/bin/bash
#
# Usage: project-migrator.sh <version> <repository-name>
#

source ./project-migrator.sh

repos_url="https://github.com/axonivy-market/"


checkRepoExists() {
  exists=$(curl -s -o /dev/null -w "%{http_code}" "${repos_url}${repo}")
  if [ $exists -ne 200 ]; then
    echo "Repo ${repos_url}${repo} does not exist"
    exit 1
  fi
}

cloneRepo() {
  if ! [ -d "${repo}" ]; then
    git clone "${repos_url}${repo}"
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
  git commit -m "Update maven version to ${convert_to_version}"
}


checkRepoExists
cloneRepo
downloadEngine

cd ${repo}
branch="raise-to-${convert_to_version}"
git switch -c $branch

raiseProject
updateMavenVersion
git push --set-upstream origin $branch
cd ..
