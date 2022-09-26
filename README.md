# Axon Ivy Market Artifacts update scripts

Scripts that make it much easier and quicker to update the Axon Ivy Market Artifacts.

## Usage

Go to actions on this github page and run the workflow `Raise Market Products`.
In the `github repository name` input field enter the name of the repository you want to update.
If the input field is empty, the script will update all repositories from `axonivy-market` organization
with some exceptions (see "raise-all-market-products.sh" at [line 27](https://github.com/axonivy-market/update-scripts/blob/a5375f8a4026475a281a3f445d28ab37d82ec45d/raise-all-market-products.sh#L27) 
and [line 6](https://github.com/axonivy-market/update-scripts/blob/a5375f8a4026475a281a3f445d28ab37d82ec45d/raise-all-market-products.sh#L6)).
