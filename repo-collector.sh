#!/usr/bin/env bash

log() {
  echo "[repo-collector] $*" >&2
}

log "Starting repo collection"

ignored_repos=(
  "market-up2date-keeper"
  "market"
  "market-monitor"
  "demo-projects"
)

log "ignored_repos=${ignored_repos[*]}"

org=thuy-org
log "org=${org}"

githubRepos() {
  ghApi="orgs/${org}/repos?per_page=100"
  log "GET https://api.github.com/${ghApi}"
  curl -s https://api.github.com/${ghApi}
}

githubReposC() {
  rm -f /tmp/gh-thuy-org.json
  cache="/tmp/gh-${org}.json"
  log "cache=${cache}"

  if [ ! -f "${cache}" ]; then
    log "cache miss → fetching repos"
    githubRepos > "${cache}"
  else
    log "cache hit"
  fi

  repo_count=$(jq length "${cache}")
  log "repos_in_cache=${repo_count}"

  # IMPORTANT: JSON ONLY to stdout
  cat "${cache}"
}

collectRepos() {
  log "Collecting eligible repositories"

  repos=$(githubReposC |
    jq -r '.[] |
      select(.archived == false) |
      select(.is_template == false) |
      select(.default_branch == "master") |
      select(.language != null) |
      .name'
  )

  log "eligible_repo_count=$(echo "${repos}" | wc -l | tr -d ' ')"
  log "eligible_repos:"
  echo "${repos}" | sed 's/^/  - /' >&2

  # ✅ ONLY repo names to stdout
  echo "${repos}"
}
