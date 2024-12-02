# Axon Ivy Market Artifacts update scripts

Scripts that make it much easier and quicker to update the Axon Ivy Market Artifacts.

## Usage

Go to actions on this github page and run the workflow `Raise Market Products`.
In the `github repository name` input field enter the name of the repository you want to update.
If the input field is empty, the script will update all repositories from `axonivy-market` organization
with some exceptions (see "raise-all-market-products.sh" at [line 27](https://github.com/axonivy-market/update-scripts/blob/a5375f8a4026475a281a3f445d28ab37d82ec45d/raise-all-market-products.sh#L27) 
and [line 6](https://github.com/axonivy-market/update-scripts/blob/a5375f8a4026475a281a3f445d28ab37d82ec45d/raise-all-market-products.sh#L6)).

### Permissions

In order to run the `raise-products.yml` workflow, permissions throughout the axonivy-market org must be granted.

#### Lease
If the token is no longer valid, generate a token as follows:

- Navigate into your profile > Settings > [Developer Settings](https://github.com/settings/tokens?type=beta) > Personal Access Tokens > Fine-Grained > Generate New

    - Resource Owner = axonivy-market
    - Expiration = 30 days
    - Permissions that must granted:
      ```
      Contents=read/write
      Metadata=read/only (default)
      Pull Requests=read/write
      Workflows=read/write
      ```
    - Click: Generate Secret
    - Copy the secret to your clipboard

- Go into the [Settings](https://github.com/axonivy-market/market-up2date-keeper/settings/secrets/actions) tab of market-up2date-keeper: Security > Actions
    - Edit the secret called `GH`
    - Paste your personal token and save

- Ready: now launch your workflow 🚀️

