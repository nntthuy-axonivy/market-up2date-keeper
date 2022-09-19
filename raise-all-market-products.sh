#!/bin/bash
#
# Usage: raise-all-market-products.sh <version>
#

ignoredRepos="market|market-product|demo-projects|Apache License 2.0"
workDir=$(mktemp -d -t projectConvertXXX)

convert_to_version=$1
if [ -z "$convert_to_version" ]; then
  read -p "Please enter a version you want to convert to: " convert_to_version
fi

curl https://api.github.com/orgs/axonivy-market/repos | 
grep -e '"name"' | 
sed -e 's/"name": "//' -e 's/",//' |
while read line
do
    if [[ $line =~ $ignoredRepos ]]; then
        continue
    fi
    echo "Migrating $line"
    source ./repo-migrator.sh $convert_to_version $line
done
