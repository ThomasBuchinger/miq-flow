# ManageIQ Automate GitFlow Importer
This command line utility implements a git-based branching workflow (GitFlow) on top of the default ManageIQ Automate Import/Export Scripts.

Automation Engine is ManageIQ's way to integrate IT infrastructure into the wider Enterprise (e.g. CMDB, change management, billing, ...). This integration TODO 

# The Problem
ManageIQ does provide import/export scripts for Automate domains, however the default scripts are not compatible with GitFlow for the following reasons:
* The Importer cannot handle partial imports for Automate domains
* Since higher priority domains override lower priority ones, any domain modeling a feature-branch MUST only contain changed files (which is a concept not easily translateable into git).

# How does automate-gitflow help?
automate-gitflow uses the diff information in git to create partial domains, which can be imported with the default importer.
* Multiple people can work on the same appliance at the same time (but not on the same method)
* It is no longer a all-or-nothing decision, when promoting code from DEV to PROD
* Pull-Requests and Commit-Squashing work the way you expect them to work

# How do I use it?
DISCLAIMER: This is work-in-progress, expect things to change without warning and the occasional stack trace.
* Clone the repository onto your ManageIQ Appliance 
* Rename `example_custom.rb` to `custom.rb`. 
  * Define a global variable `$git_path` to use a local git repository
  * Define a global variable `$git_url` to clone the repository. The `$git_user` and `$git_password` are used for authentication 
  * `$master_domain`
* Run `./bin/cli.rb` with the correct `--provider` option:
  * `local`: This provider assumes running on a ManageIQ Appliance and uses the Rake Tasks of ManageIQ
  * `noop`: Preview what the scrpit would do, without modifying ManageIQ
  * `docker`: This Provider assumes a [manageiq/manageiq](https://hub.docker.com/r/manageiq/manageiq/) container running. (mostly for development)

## Commands
See `./bin/cli.rb` help for details. Basic Commands are: 
* (WIP) discover - create new domains
* deploy <branch> - deploys the code in a feature-branch
* (WIP) sync  - deploy all branches 
* (WIP) prune - remove feature-domains without a branch

## Notes
* Make sure you have [Rugged](https://github.com/libgit2/rugged) and [Thor](https://github.com/erikhuda/thor) installed (it is on the ManageIQ Appliances)
* automate-gitflow may checkout a different branch, when used with a local repository
* deploying multiple domains per feature-branch is not yet supported
