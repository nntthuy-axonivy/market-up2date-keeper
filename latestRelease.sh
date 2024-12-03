#!/bin/bash
#
# Prints a CSV formatted list of the latest release versions
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "${DIR}/repo-collector.sh"

latestReposCSV() {
  echo "repo;latestTag;latestRelease"
  collectRepos |
  while read repo_name; do
    showLatestRelease $repo_name
  done
}

showLatestRelease() {
  repo="$1"
  releases="repos/${org}/${repo}/releases/latest"
  tags="repos/${org}/${repo}/tags"
  latestTag=$(gh api "repos/${org}/${repo}/tags" | jq -r 'first.name')
  latestRelease=$(gh api "${releases}" 2> /dev/null | jq -r 'select(.draft == false).name')
  echo "$repo;$latestTag;$latestRelease"
}

latestReposCSV
