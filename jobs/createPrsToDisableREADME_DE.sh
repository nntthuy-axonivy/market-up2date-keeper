#!/bin/bash
# This script creates PRs to add CODEOWNERS and workflow to prevent modification of README_DE.md
# Add new rule in CODEOWNERS and create a GitHub Actions workflow to block changes to README_DE.md
# Enable branch protection on the default branch

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/../repo-collector.sh

DEFAULT_BRANCH="master"
REVIEWER="Octopus-AxonIvy"
README_FILE="README_DE.md"
CODEOWNERS_FILE=".github/CODEOWNERS"
CODEOWNERS_RULE="**/${README_FILE}  @axonivy-market/team-octopus"
WORKFLOW_FILE=".github/workflows/disable-readme-de.yml"
BRANCH_NAME="feature/MARP-3334-disable-README_DE-file"
PR_TITLE="Add CODEOWNERS and workflow to disable README_DE.md"

enableBranchProtection() {
  repo_name=$1
  branch=$2

  echo "Enabling branch protection for $branch in $repo_name..."
  gh api -X PUT "repos/${org}/${repo_name}/branches/${branch}/protection" \
    --input - <<'JSON'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["prevent-modification"]
  },
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1
  },
  "enforce_admins": false,
  "restrictions": null
}
JSON

  if [ $? -eq 0 ]; then
    echo "✓ Branch protection enabled successfully"
  else
    echo "⚠ Failed to enable branch protection (may require admin permissions)"
  fi
}

createPR() {
  repo_name=$1
  git clone "https://github.com/${org}/${repo_name}.git"
  cd "${repo_name}"

  # Loop through directories to find product folder with README_DE.md
  found_readme=false
  for dir in */; do
    if [[ "$dir" == *"product"* ]]; then
      if [ -f "${dir}${README_FILE}" ]; then
        found_readme=true
        echo "Found ${README_FILE} in $dir"
        break
      fi
    fi
  done

  if [ "$found_readme" = false ]; then
    echo "⚠ ${README_FILE} not found in any product folder of $repo_name, skipping...!"
    cd ..
    rm -rf "${repo_name}"
    return
  fi

  # Checkout new branch.
  if git ls-remote --heads origin "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
    echo "⚠ Branch $BRANCH_NAME already exists in $repo_name"
    git checkout "$BRANCH_NAME"
  else
    git checkout -b "$BRANCH_NAME"
  fi

  changes_made=false

  mkdir -p .github
  if [ -f "${CODEOWNERS_FILE}" ]; then
    if ! grep -q "${README_FILE}" "${CODEOWNERS_FILE}"; then
      echo "✓ Adding ${README_FILE} to existing CODEOWNERS"
      printf "\n${CODEOWNERS_RULE}\n" >> "${CODEOWNERS_FILE}"
      changes_made=true
    else
      echo "⚠ ${README_FILE} already in CODEOWNERS"
    fi
  else
    echo "✓ Creating new CODEOWNERS file"
    cat > "${CODEOWNERS_FILE}" << EOF
${CODEOWNERS_RULE}
EOF
    changes_made=true
  fi

  mkdir -p .github/workflows
  
  if [ ! -f "${WORKFLOW_FILE}" ]; then
    echo "✓ Creating workflow to disable ${README_FILE}"
    cat > "${WORKFLOW_FILE}" << 'WORKFLOW_EOF'
name: Disable README_DE.md

on:
  pull_request:

jobs:
  prevent-modification:
    runs-on: ubuntu-latest
    steps:
      - name: Check out code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Check PR author
        id: check_author
        run: |
          PR_AUTHOR="${{ github.event.pull_request.user.login }}"
          echo "PR author: $PR_AUTHOR"
          
          if [ "$PR_AUTHOR" = "weblate" ]; then
            echo "✓ Author is weblate, bypassing README_DE.md check"
            echo "bypass=true" >> $GITHUB_OUTPUT
          else
            echo "Author is not weblate, will check README_DE.md modifications"
            echo "bypass=false" >> $GITHUB_OUTPUT
          fi
          
      - name: Check if README_DE.md existed on default branch
        if: steps.check_author.outputs.bypass != 'true'
        run: |
          git fetch origin ${{ github.base_ref }}
          if git ls-tree -r origin/${{ github.base_ref }} --name-only | grep -q 'README_DE\.md$'; then
            echo "README_DE.md exists, checking for modification"
            # Check if file content changed vs. base branch
            if ! git diff --exit-code origin/${{ github.base_ref }}...HEAD -- '**/README_DE.md'; then
              echo "⚠ ERROR: Modification of README_DE.md is not allowed."
              exit 1
            fi
          else
            echo "✓ README_DE.md does not exist on default branch, file can be created."
          fi
WORKFLOW_EOF
    changes_made=true
  else
    echo "⚠ Workflow file already exists"
  fi

  # Commit and push changes
  if [ "$changes_made" = true ]; then
    git add "${CODEOWNERS_FILE}" "${WORKFLOW_FILE}"
    
    if git diff --cached --quiet; then
      echo "No changes to commit for $repo_name"
      cd ..
      rm -rf "${repo_name}"
      return
    fi

    git commit -m "Add CODEOWNERS and workflow to disable ${README_FILE}"

    git push origin "$BRANCH_NAME"

    pr_id=$(gh pr list --head "$BRANCH_NAME" --base master --json number --jq '.[0].number')

    if [ -z "$pr_id" ]; then
      echo "Creating pull request"
      pr_body="This PR adds protection to disable README_DE.md"

      gh pr create --title "$PR_TITLE" --body "$pr_body" --base master --head "$BRANCH_NAME" --reviewer "$REVIEWER"
      echo "✓ Pull request created successfully"
    else
      echo "⚠ Pull request already exists for branch $BRANCH_NAME (PR #$pr_id)"
    fi
    
    # Enable branch protection after PR is created
    cd ..
    enableBranchProtection "$repo_name" "$DEFAULT_BRANCH"
    cd "${repo_name}"
  else
    echo "No changes needed for $repo_name"
  fi

  cd ..
  rm -rf "${repo_name}"
}

main() {
  echo "Working Organization: ${org}"
  echo "Ignored repositories: ${ignored_repos[@]}"
  collectRepos | while read -r repo_name; do
    repo_name=$(echo "$repo_name" | sed 's/\r//g')
    if [[ " ${ignored_repos[@]} " =~ " ${repo_name} " ]]; then
      echo "⚠ Ignoring repo: ${repo_name}"
      continue
    fi
    echo "Processing repo: $repo_name"
    createPR "$repo_name"
  done
}

main
