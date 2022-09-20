#!/bin/bash
#
# Usage: raise-all-market-products.sh <version>
#

ignored_repos=(
  "market"
  "market-product"
  "demo-projects"
  "github-workflows"
  "Apache License 2.0"
)

if [ -z "$workDir" ]; then
  workDir=$(mktemp -d -t projectConvertXXX)
fi

convert_to_version=$1
if [ -z "$convert_to_version" ]; then
  echo "Missing target version parameter e.g 9.4.0"
  exit 1
fi


collectRepos() {
  curl https://api.github.com/orgs/axonivy-market/repos | 
  grep -e '"ssh_url"' | 
  sed -e 's/"ssh_url": "//' \
      -e 's/",//'
}

migrateListOfRepos() {
  collectRepos |
  while read repo; do
    migrateRepo $repo
  done
}

migrateRepo() {
  repo=$1
  if [[ $repo =~ $ignored_repos ]]; then
    echo "Skipping repository $repo"
  else
    echo "Migrating $repo to $convert_to_version"
    source ./repo-migrator.sh
  fi
}

repo_name=$2
if [ -z "$repo_name" ]; then
  migrateListOfRepos
else
  migrateRepo $repo_name
fi

