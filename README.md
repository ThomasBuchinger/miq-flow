# ManageIQ Workflow Automate Importer
[![Build Status](https://travis-ci.org/ThomasBuchinger/miq-flow.svg?branch=master)](https://travis-ci.org/ThomasBuchinger/miq-flow)

This command line utility enables the use of git feature branches on top of the default ManageIQ Automate Export/Import scripts.

## The Problem
ManageIQ handles multiple code trees (Automate Domains) using a priority based lookup, this limits the codebase to one `master` and one shared `develop` branch for all developers.

At the same time it is common for ManageIQ deployments to have a shared DEV environment, as custom Automate Methods often depend on:
* External services called via REST
* Additional permissions (e.g. firewall clearing, administrative accounts, ...)

## How does miq-flow help?
miq-flow uses the version history in git to enable "feature-domains", which avoid the lookup problem ([Details](doc/concept.md)).

* Multiple people can work on the same appliance at the same time (but not on the same method)
* Promoting code is no longer a all-or-nothing decision
* Pull-Requests and Commit-Squashing work the way you expect them to work
* Code is cloned from a remote repository, if it is not already on the appliance
* Manual changes on the WebUI are still possible ([Details](doc/user_guide.md#release-the-code))

# How do I use it?
* Download and install the `miq_flow` gem from [GitHub](https://github.com/ThomasBuchinger/miq-flow/releases)
* Configure miq-flow:
  * Use CLI parameter (see `miq-flow help`) or environment variables
  * Download and edit the configuration file: `curl -o ~/.miqflow.yaml https://raw.githubusercontent.com/ThomasBuchinger/miq-flow/master/config.yaml`
* Run `./bin/miq-flow deploy BRANCH` with the correct `--provider` option:
  * `local`: This provider assumes running on a ManageIQ Appliance and uses the evm:automate:import rake task (you want to use this one)
  * `noop`: Preview what the miq-flow would do, without modifying ManageIQ
  
For additional instructions see the full [installation guide](doc/user_guide.md) or run miq-flow from [source](doc/developer.dm#setup-local-development)

## Commands
See `miq-flow help` for details. Basic Commands are: 
* branch list - lists a summary for each branch in git
* branch inspect _BRANCH_ - show details of a given branch
* domain list - lists Automate Domains found in ManageIQ
* deploy _BRANCH_ - deploys the code in a feature-branch

## Notes
* miq-flow assumes to run on a ManageIQ appliance, since there is no way to remotely import Automate Domains
* Make sure you have [Rugged](https://github.com/libgit2/rugged), [RestClient](https://github.com/rest-client/rest-client) and [Thor](https://github.com/erikhuda/thor) installed (it is on the ManageIQ Appliances).
* miq-flow may checkout a different branch, when used with a local repository
