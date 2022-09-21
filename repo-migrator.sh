#!/bin/bash
#
# Usage: project-migrator.sh <version> <repository-name>
#

source ./project-migrator.sh

repo_url="https://github.com/axonivy-market/${repo_name}"
clone_url="git@github.com:axonivy-market/${repo_name}.git"

checkRepoExists() {
  exists=$(curl -s -o /dev/null -w "%{http_code}" "${repo_url}")
  if [ $exists -ne 200 ]; then
    echo "Repo ${repo_url} does not exist"
    exit 1
  fi
}

cloneRepo() {
  if ! [ -d "${repo}" ]; then
    git clone "${clone_url}"
  fi
}

updateMavenVersion() {
  # update version in pom.xml
  # loop through all folders
  for d in */ ; do
    echo "Updating $d"
    mvn -f $d -B versions:set -DnewVersion=$convert_to_version -DgenerateBackupPoms=false -DprocessAllModules=true
    mvn -f $d -B versions:use-latest-versions -DgenerateBackupPoms=false -DprocessAllModules
  done

  # commit changes
  git add .
  git commit -m "Update maven version to ${convert_to_version}"
}

push() {
  has_unpushed_commits=$(git log --branches --not --remotes)
  if [ -z "$has_unpushed_commits" ]; then
    echo "No changes to push for ${repo_name}"
  else
    echo "Pushing changes of ${repo_name}"
    git push --set-upstream origin $branch
    echo "${repo_url}" >> ${workDir}/migrated-repos.txt
  fi
}


checkRepoExists
downloadEngine
cloneRepo

cd ${repo}
branch="raise-to-${convert_to_version}"
git switch -c $branch

raiseProject
updateMavenVersion
push
cd ..
