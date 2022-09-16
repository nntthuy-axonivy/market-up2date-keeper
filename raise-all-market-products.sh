#!/bin/bash
ignoredRepos="axonivy-market/market|axonivy-market/market-product"

convert_to_version=$1
if [ -z "$convert_to_version" ]; then
  read -p "Please enter a version you want to convert to: " convert_to_version
fi

curl https://api.github.com/orgs/axonivy-market/repos |
grep -e 'ssh_url*' |
sed -e 's/"ssh_url": "//' -e 's/",//' |
while read line
do
    if [[ $line =~ $ignoredRepos ]]; then
        continue
    fi
    source ./repo-migrator.sh $convert_to_version $line
done

