# ManageIQ Workflow Automate Importer
[![Build Status](https://travis-ci.org/ThomasBuchinger/automate-gitflow.svg?branch=master)](https://travis-ci.org/ThomasBuchinger/automate-gitflow)
[![Maintainability](https://api.codeclimate.com/v1/badges/1f99f924fb2c4536a28e/maintainability)](https://codeclimate.com/github/ThomasBuchinger/miq-flow/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/1f99f924fb2c4536a28e/test_coverage)](https://codeclimate.com/github/ThomasBuchinger/miq-flow/test_coverage)

This command line utility implements a git-based branching workflow on top of the default ManageIQ Automate Import scripts.

Automation Engine is ManageIQ's way to integrate IT infrastructure into the wider Enterprise (e.g. CMDB, change management, billing, ...).
It is common for ManageIQ deployments to have a shared DEV environment, because custom Automate Methods depend on:
* External services called via REST
* Naming conventions in the virtual infrastructure 
* Additional permissions (e.g. firewall clearing, administrative accounts, ...)

# The Problem
ManageIQ can handle multiple code trees (Automate Domains) using a priority based lookup, this limits the codebase to one `master` and one shared `develop` branch for all developers.
To support mutliple feature branches, one has to:
1. Find the files changed in a given feature branch
1. Import only changed files, instead of everything

miq-workflow is a command line tool, that uses the diff information in git to create partial domains and imports them in ManageIQ

# How does miq-workflow help?
* Multiple people can work on the same appliance at the same time (but not on the same method)
* Promoting code is no longer a all-or-nothing decision
* Pull-Requests and Commit-Squashing work the way you expect them to work
* Code is cloned from a remote repository, if it is not already on the appliance
* Manual changes on the WebUI are still possible (although a bit tricky)

# How do I use it?
* Clone the repository onto your ManageIQ Appliance
* Open `config.yaml` file and make sure you configure `git.url` and `miq.url` options
* Run `./bin/miq-workflow deploy BRANCH` with the correct `--provider` option:
  * `local`: This provider assumes running on a ManageIQ Appliance and uses the evm:automate:import rake task (you want to use this one)
  * `noop`: Preview what the script would do, without modifying ManageIQ
  * `docker`: This Provider assumes a [manageiq/manageiq](https://hub.docker.com/r/manageiq/manageiq/) container running. (mostly for development)

## Commands
See `./bin/miq-workflow` help for details. Basic Commands are: 
* list git - lists a summary for each branch in git
* list miq - lists Automate Domains found in ManageIQ
* inspect _BRANCH_ - show details of a given branch
* deploy _BRANCH_ - deploys the code in a feature-branch
* (WIP) prune - remove feature-domains without a branch

## Notes
* miq-workflow assumes to run on a ManageIQ appliance, since there is no way to remotely import Automate Domains
* Make sure you have [Rugged](https://github.com/libgit2/rugged), [RestClient](https://github.com/rest-client/rest-client) and [Thor](https://github.com/erikhuda/thor) installed (it is on the ManageIQ Appliances).
* miq-workflow may checkout a different branch, when used with a local repository
