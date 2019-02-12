# Reference
> WIP: Please stand by

## Motivation (own file)
### starting point?

### Problems
* single DEV -> disabling in-progress-code
* "disabled" in-progess code still makes it to PROD

### Benefits
* local development
* PRs work
* (for large codebases) bettter overview over changes
* contributions over git
* source of truth in git
* possible to use git domains


## Proxy Support
Use http_proxy ENV var

## Confiuration Options
### Use a local repository

## Provider
Technically Miq-Flow also needs know, how to access to ManageIQ's `evm:automate:import` rake task, in addition to the git repository and  
Since we are running on the appliance and the only real provider is local, we do not need to configure it

## Naming conventions
Miq-Flow uses a part of the branch name as name for the Automate domains it creates. Branch names in git often follow a naming convention (e.g. `<type>-<name-or-ref>-<description>`), which are long and/or contain illegal characters for Automate domains. Therefore miq-flow renames it's Automate domains as `feat_<NAME>_<BASE-NAME>`. 

In case you use any other naming convention, miq-flow uses a simple index to figure out which part is the `NAME`. Configurable via the `git.seperators` and `git.index` parameters 

> These automatic names can be overwritten by a command line flag. But some features in the future may rely on this automatic naming to match Automate domains in ManageIQ the branches in git.

## Glossary
* `Automate code` general term for code written for ManageIQ's Automation Engine
* `base domain` Automate domain for "released" code. In git term this would correspond to the master branch
* `feature domain` Automate domain for a single feature. In-progress code, that contains only the subset of methods that were changed to implement a feature.
  
