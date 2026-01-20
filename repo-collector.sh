# re-usable collection of market repos to modify

ignored_repos=(
  "market-up2date-keeper"
  "market"
  "market-monitor"
  "demo-projects"
)

# GitHub organization to work on
# For testing, please use a personal org
org=thuy-org

githubRepos() {
  echo "[repo-collector] Fetching repositories from GitHub API (no cache)"
  ghApi="orgs/${org}/repos?per_page=100"
  echo "[repo-collector] githubRepos → GET https://api.github.com/${ghApi}"
  curl https://api.github.com/${ghApi}
}

githubReposC() {
  cache="/tmp/gh-${org}.json"
  echo "[repo-collector] cache=${cache}"

  if [ ! -f "${cache}" ]; then
    echo "[repo-collector] cache miss → fetching repos"
    githubRepos > "${cache}"
  else
    echo "[repo-collector] cache hit"
  fi

  # Print number of repos retrieved
  repo_count=$(jq length "${cache}")
  echo "[repo-collector] repos_in_cache=${repo_count}"

  cat "${cache}"
}

collectRepos() {
  echo "[repo-collector] Collecting eligible repositories"
  githubReposC | 
    jq -r '.[] | 
    select(.archived == false) | 
    select(.is_template == false) | 
    select(.default_branch == "master") | 
    select(.language != null) | 
      .name'
  echo "[repo-collector] eligible_repos:"
  if [ -z "${repos}" ]; then
    echo "  (none)"
  else
    while read -r repo; do
      echo "  - ${repo}"
    done <<< "${repos}"
  fi

  # IMPORTANT: return the repos for callers (e.g. GitHub Actions)
  echo "${repos}"
}
