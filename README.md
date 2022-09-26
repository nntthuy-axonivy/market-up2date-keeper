# Axon Ivy Market Artifacts update scripts

Scripts that make it much easier and quicker to update the Axon Ivy Market Artifacts.

## Usage

Go to actions on this github page and run the workflow `Raise Market Products`.
In the `github repository name` input field enter the name of the repository you want to update.
If the input field is empty, the script will update all repositories from `axonivy-market` organization
excluding archived and template repositories as well as repositories that don't have master branch as default branch
and don't have a [repository language](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-repository-languages).
