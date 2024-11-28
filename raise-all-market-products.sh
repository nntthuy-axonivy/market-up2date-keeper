#!/bin/bash
#
# Usage: raise-all-market-products.sh <version>
#

ignored_repos=(
  "market-up2date-keeper"
  "market"
  "market-monitor"
  "demo-projects"
)

org=axonivy-market

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$workDir" ]; then
  workDir=$(mktemp -d -t projectConvertXXX)
fi

if [ -z "$gitDir" ]; then
  gitDir="$DIR/repos"
  echo $(mkdir -v -p $DIR/repos)
fi

convert_to_version=$1
if [ -z "$convert_to_version" ]; then
  echo "Missing target version parameter e.g 9.4.0-SNAPSHOT"
  exit 1
fi

if [[ ! $convert_to_version == *-SNAPSHOT ]]; then
  echo "Version must be SNAPSHOT e.g 9.4.0-SNAPSHOT"
  exit 1
fi


githubRepos() {
  gh auth status
  ghApi="orgs/${org}/repos?per_page=100"
  gh api https://api.github.com/${ghApi}
}

githubReposC(){
  cache="/tmp/gh-${org}.json"
  if [ ! -f "${cache}" ]; then
    githubRepos > "${cache}"
  fi
  cat "${cache}"
}

collectRepos() {
  githubReposC | 
    jq -r '.[] | 
    select(.archived == false) | 
    select(.is_template == false) | 
    select(.default_branch == "master") | 
    select(.language != null) | 
      .name'
}

showMigratedRepos() {
  log="${workDir}/migrated-repos.txt"
  if [ -f $log ]; then
    echo "Migrated repos:"
    cat $log
  fi
}

migrateListOfRepos() {
  collectRepos |
  while read repo_name; do
    migrateRepo $repo_name
  done
  showMigratedRepos
}

migrateRepo() {
  cd ${gitDir}
  repo=$1
  if [[ " ${ignored_repos[@]} " =~ " ${repo} " ]]; then
    echo "Ignoring repo ${repo}"
  else
    echo "Migrating $repo to $convert_to_version"
    source "$DIR/repo-migrator.sh"
  fi
  cd $DIR
}

repo_name=$2
if [ -z "$repo_name" ]; then
  migrateListOfRepos
else
  migrateRepo $repo_name
fi

