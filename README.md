# Github Actions - Self Hosted Agents on AKS

This repo provides instructions and configuration to setup Self Hosted Agents for Github running on an AKS cluster.  It was derived from this [article](https://github.blog/2020-08-04-github-actions-self-hosted-runners-on-google-cloud/) by [John Bohannon](https://github.com/imjohnbo).   This project utilizes terraform and helm to provide support for a repeatable infrastructure as code approach.  The process can also be orchestrated through an **Github workflow**. 

## Setup

Fork this repo and pull your fork to your computer

Cd into the repo

Ensure you have the following dependencies:
- [jq](https://stedolan.github.io/jq/download/)
- [azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (logged in to a subscription where you have contributor rights)
- [github-cli](https://cli.github.com/) (logged in)
- [Create a github personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) -- and export the value -- export GITHUB_TOKEN=paste_your_token_here

Run the setup.sh script
- Syntax: **. ./setup.sh** [-c CLUSTER_NAME] [-g RESOURCE_GROUP_NAME] [-s SUBSCRIPTION_ID] [-r REGION] (the extra dot is important)
- make setup_cmd provides an example version

This script does the following:
    - Create a service principal for use by terraform
    - Create a storage account to keep the terraform state
    - Create a resource group where your AKS cluster will be deployed
    - Save service principal and other provided variables in github secrets
    
If running locally:

- export the following variables with the appropriate values
    - GITHUB_REPO_OWNER: "your github id"
    - GITHUB_REPO_NAME: "your github repo name"
    - GITHUB_REPO_URL: "https://github.com/${GITHUB_REPO_OWNER}/${GITHUB_REPO_URL}"
- make all_terraform
- make all_ghr

This uses the repo makefile to create your AKS cluster, create an ACR, and deploy the runner to the cluster

## Next steps

- dynamically set repo owner/repo name
- check for GITHUB_TOKEN before deploying
- remove helm install note
- check for all other variables in makefile (gh secret get?)
- add workflow / instructions
- Validate setup for an organization
- Multiple node pool
- Cluster autoscaling
- Virtual nodes?

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.

