org="axonivy-market"
default_branch="master"
reviewer_name="nameofreviewer"

ignored_repos=(
  "market-up2date-keeper"
  "market.axonivy.com"
  "market-monitor"
  "market"
  "demo-projects"
  "portal"
  "marketplace"
  "api-proxy"
  "bpmn-assistant"
  "market-product"
  "msgraph-connector"
  "portal-ai"
  "mobileapp"
  "amazon-aws4-authenticator"
  ".github"
  "github-workflows"
  "jira-cloud-connector"
  "hubspot-connector"
  "doc-factory"
  "successfactors-connector"
  "ui-path-connector"
  "talentLink-connector"
)

# Function to collect repositories based on filters
collectRepos() {
  githubRepos | 
    jq -r '.[] | 
    select(.archived == false) | 
    select(.is_template == false) | 
    select(.default_branch == "master") | 
    select(.language != null) | 
      .name' | sed 's/\r//g'
}

# Function to retrieve repositories from the GitHub API
githubRepos() {
  ghApi="orgs/${org}/repos?per_page=100"
  gh api "${ghApi}"
}

# Create prs
createPR() {
  repo_name=$1
  echo "Creating PRs for repository: $repo_name"
  # Ensure repo name has no carriage return characters
  repo_name=$(echo "$repo_name" | sed 's/\r//g')

  # Pass ignored repositories  
  if [[ " ${ignored_repos[@]} " =~ " ${repo_name} " ]]; then
    echo "Ignoring repo ${repo_name}"
    return
  fi

  #Cloning repository to local
  git clone "https://github.com/${org}/${repo_name}.git"
  cd "${repo_name}"

  # Loop through directories to find product folder.
  for dir in */; do
      if [[ "$dir" == *"product"* ]]; then
        cd "${dir}"
        pom_file=$(find -name "pom.xml" | head -n 1)
        zip_file=$(find -name "zip.xml" | head -n 1)
        echo "Found pom.xml and zip.xml at folder: $dir"

        # Define branch and PR
        branch_name="feature/MARP-1333-add-missing-readme"
        pr_title="MARP-1333 Missing setup path for README_DE.md"

        # Checkout new branch.
        if git ls-remote --heads origin "$branch_name" | grep -q "$branch_name"; then
            echo "Branch $branch_name already exists in $repo_name"
            git checkout "$branch_name"
        else
            git checkout -b "$branch_name"
        fi
        
        
        echo "Including README_DE.md in zip.xml"
        # Includes README_DE.md in zip.xml
        sed -i '/<include>README.md<\/include>/a \
                <include>README_DE.md<\/include>' "$zip_file"
        # Check if maven-antrun-plugin is already present
        echo "Adding README_DE to $pom_file"
         # Set variables to README_DE.md.
        sed -i '/<replace file="\${project.build.directory}\/README.md" token="@variables.yaml@" value="\${variables.yaml}"/a \
                <copy file="README_DE.md" tofile="${project.build.directory}/README_DE.md"/>\
                <replace file="${project.build.directory}/README_DE.md" token="@variables.yaml@" value="${variables.yaml}"/>
                ' "$pom_file"

        # Convert all line endings in the file to CRLF
        sed -i 's/$/\r/' "$pom_file"

        # Add changes.
        git add .

        #Commit changes
        git commit -m "MARP-1333 Missing setup path for README_DE.md"
        git push origin "$branch_name"

        #Define and create PR
        pr_id=$(gh pr list --head "$branch_name" --base master --json number --jq '.[0].number')

        if [ -z "$pr_id" ]; then
            echo "Creating pull request"
            gh pr create --title "$pr_title" --body "Included README_DE.md in pom.xml and zip.xml" --base master --head "$branch_name" --reviewer "$reviewer_name"
            pr_id=$(gh pr list --head "$branch_name" --base master --json number --jq '.[0].number')
        else
            echo "Pull request already exists for branch $branch_name"
        fi
        cd ..
      fi 
    done
    cd ..
    rm -rf "${repo_name}"

}

main() {
  echo "Repositories found:"
  collectRepos | while read -r repo_name; do
    echo "Checking repo: $repo_name"
    createPR "$repo_name"
  done
}

main
