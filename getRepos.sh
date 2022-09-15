#!/bin/bash
ignoredRepos="axonivy-market/market|axonivy-market/market-product"

curl https://api.github.com/orgs/axonivy-market/repos |
grep -e 'ssh_url*' |
sed -e 's/"ssh_url": "//' -e 's/",//' |
while read line
do
    if [[ $line =~ $ignoredRepos ]]; then
        continue
    fi
    git clone $line
done

