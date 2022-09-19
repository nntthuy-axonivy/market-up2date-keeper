#!/bin/bash
#
# Usage: raise-all-market-products.sh <version>
#

ignoredRepos=(
  "market"
  "market-product"
  "demo-projects"
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
  grep -e '"name"' | 
  sed -e 's/"name": "//' \
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
  if [[ $repo =~ $ignoredRepos ]]; then
    echo "Skipping repository $repo"
  else
    echo "Migrating $repo to $convert_to_version"
    source ./repo-migrator.sh $convert_to_version $repo
  fi
}

repoName=$2
if [ -z "$repoName" ]; then
  migrateListOfRepos
else
  migrateRepo $repoName
fi

