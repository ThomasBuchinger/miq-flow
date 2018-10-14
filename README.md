# ManageIQ Automate GitOps Importer
This command line utiity extends the default ManageIQ Automate Import/Export Scripts to work better in a git-based branching workflow (GitFlow).

# The Problem
ManageIQ does provide import/export scripts for Automate domains, however the default scripts are not compatible with GitFlow for the following reasons:
* The Importer cannot handle partial imports for Automate domains
* Since higher priority domains shadow lower priority ones, any domain modeling a feature-branch MUST only contain changed files (which is a concept not easily translateable into git).

# How does automate-gitflow help?
automate-gitflow uses the diff information in git to create partial domains, which can be imported with the default importer.
* Multiple people can work on the same appliance at the same time (but not on the same method)
* It is no longer a all-or-nothing decision, when promoting code from DEV to PROD
* Pull-Requests and Commit-Squashing work the way you expect them to work

# How do I use it?
DISCLAIMER: 
* This is a first commit, and there is still stuff hardcoded.
* The only Provider is a local Docker Container (at the moment)

## Commands (there is no CLI yet)
* discover - create new domains
* deploy <branch> - deploys the code in one
* sync  - deploy all branches 
* prune - remove feature-domains without a branch

## Notes
* Make sure you have [Rugged](https://github.com/libgit2/rugged) (it is on the ManageIQ Appliances)
* You have to checkout the Automate Code Repository yourself
* automate-gitflow will not modify any files in the repository, however it will do checkouts
