# User Guide
This is a step-by-step guide to miq-flow and how to setup everything you need. This guide assumes a running ManageIQ appliance using the [Quick Start](http://manageiq.org/docs/get-started/) or [Installation Guide](http://manageiq.org/docs/get-started/). We will also assume, that you are running at least two appliances, one in a development environment where you develop your Automate code and another production appliance where the released code runs.

>**Note**: You don't need to setup the production appliance to follow the guide, but it will explain how you would get the code from development to production. 

We assume familiarity with git and typical branching workflows. Although this project is named after the original [Gitflow workflow](https://nvie.com/posts/a-successful-git-branching-model/) by Vincent Driessen, many projects prefer a simplified worklflow  (see [Github flow](https://guides.github.com/introduction/flow/) or Atlassian's [Workflow comparisson](https://www.atlassian.com/git/tutorials/comparing-workflows) and [feature branch workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow)) for small scale use-cases like this one, feel free to mix and match any number of ideas to fit your needs.

This guide assumes some sort of "Export from DEV > Commit to git > Import in PROD" workflow already setup to move Automate code from a development appliance to a production appliance. If you don't have something similar, the guide will walk you trough the important parts, to get everyone on the same page.  
If you have already moved on from there, you may still find some use case for miq-flow.

- [Miq-Flow Setup](#miq-flow-setup)
  - [Prerequisites:](#prerequisites)
  - [Miq-Flow Installation](#miq-flow-installation)
  - [Setup the Repository](#setup-the-repository)
  - [Configure Miq-Flow](#configure-miq-flow)
  - [Setup basic Export/Import (Outline)](#setup-basic-exportimport-outline)
- [Develop Code](#develop-code)
  - [Make a Change](#make-a-change)
  - [View your change](#view-your-change)
  - [Test your change](#test-your-change)
  - [Repeat](#repeat)
- [Release the code](#release-the-code)
  - [Option 0: Manual Copy](#option-0-manual-copy)
  - [Option 1: Double down on git](#option-1-double-down-on-git)
    - [Lock down base domain](#lock-down-base-domain)
  - [Option 2a: Overwriting Export](#option-2a-overwriting-export)
    - [Review "Export from DEV > Commit to git > Import to PROD" workflow](#review-%22export-from-dev--commit-to-git--import-to-prod%22-workflow)
    - [Configure the Rebase](#configure-the-rebase)
  - [Option 2b: Miq-Flow-Exporter](#option-2b-miq-flow-exporter)

The 1st part sets up a basic "Export from DEV > Commit to git > Import to PROD" workflow and walk you through installing and configuring miq-flow.  
The 2nd part describes the day-to-day development cycle using miq-flow.  
The 3rd part will outline 2 options to deploy your Automate code and Customizations (like Buttons, Dialogs, ...).  
* **Git workflow** with this option, the goal is to move as much as possible into git. Resulting in a very clean workflow, with explicit exceptions for things that do not translate well to git.
* **Export workflow** with this option, the goal is to extend the current Export/Import workflow with feature branches in git. It takes extra effort to setup, but the whole workflow stays as clean (or messy) as it is.

# Miq-Flow Setup

## Prerequisites:
* You want to install miq-flow on a ManageIQ appliance, miq-flow needs access to the ManageIQ rake tasks ([Reason](reference.md#provider)) and the appliance satisfies the gem dependencies.
* If you need to use **proxies** [notice this notice](reference.md#proxy-support) on the subject. Your noticing has been noted. Thank you.
* Your Repository should be accessible via HTTPS. [Reason](reference.md#ssh-support)

## Miq-Flow Installation
Miq-Flow comes as a Gem, which installs a command line utility named `miq-flow`. It is not on rubygems.org, therefore you have to download it yourself.
* Make sure you have a internet connection.
* Make sure the link below is still up to date.
* Download the Gem: `curl -o miq_flow.gem -L https://github.com/ThomasBuchinger/miq-flow/releases/download/v1.0.0-rc1/miq_flow-1.0.0.pre.rc1.gem`
* Install the Gem: `gem install miq_flow`
* Create a configuration. You can choose to provide the necessary configuration as YAML file (see below), as  CLI prameter or as ENV variables.  
  Make sure you place the config file in the users `$HOME` directoy or in `/etc/miqflow.yaml`.
  Download the example configuration: `curl -o ~/.miqflow.yaml https://raw.githubusercontent.com/ThomasBuchinger/miq-flow/v1.0.0-rc1/config.yaml`

Check if the gem is correctly installed by running `miq-flow help`.

> Run from [Source](developer.md#setup-local-development)

## Setup the Repository
ManageIQ - UI
* Login to your ManageIQ appliance and navigate to 'Automation > Automate > Explorer'
* Create a new Domain. This will be the base domain, that will correspond to your `master` branch.
* **Optional**: Create a second domain if you use multiple domains already.  
  This step is only to showcase, how miq-flow handles multiple base domains.
* Copy some Code from the ManageIQ domain to your own.

ManageIQ - Appliance
* Connect to your ManageIQ apppliance over SSH. 
* Create a working direcory on your appliance: `mkdir /root/miq-flow-tutorial`
* Change to the vmdb directory by running `vmdb`.
* Export your domain: `rake evm:automate:export DOMAIN=buc EXPORT_DIR=/root/miq-flow-tutorial/automate`  
  Export the second domain (if you have one) and any other Customizations (Buttons, Dialogs, ...).

Commit to GIT:
* Create a new empty repository on your git account.
* Change to your export directroy.
* Commit and push everything to GIT:
  ```shell
  git init
  git add --all
  git commit -m "first commit"
  git remote add origin <your-repo-url>
  git push -u origin master
  ```

## Configure Miq-Flow
Miq-Flow needs to know where your code is and how to connect to ManageIQ's API.

> `git.url: <your-repo-url>`  
> This is the URL to your git repository. Miq-Flow will clone that repository automatically in the background.
>
> `miq.url: https://localhost/api`  
> API Endpoint for ManageIQ.
>
> `miq.user: admin`  
> `miq.password: smartvm`  
> ManageIQ API credentials.

Check if miq-flow works by running `miq-flow branch list` and `miq-flow domain list`. Your output should be similar to the example below.
```shell
$ miq-flow branch list
I, [2019-01-30T02:54:16.467144 #10109]  INFO -- : Processing config file: /root/.miqflow.yaml
I, [2019-01-30T02:54:16.469575 #10109]  INFO -- : Cloning git Repository from: https://github.com/ThomasBuchinger/miq-flow-example
origin/master: feat_master_buc: 0 feat_master_buc_lib: 0

miq-flow domain list
I, [2019-01-30T02:55:34.228987 #10216]  INFO -- : Processing config file: /root/.miqflow.yaml
I, [2019-01-30T02:55:34.230449 #10216]  INFO -- : Cloning git Repository from: https://github.com/ThomasBuchinger/miq-flow-example
buc: ID=77 Enabled=yes Prio=2 Last Update=45 minutes ago
buc_lib: ID=78 Enabled=yes Prio=1 Last Update=45 minutes ago
ManageIQ (Base domain): ID=1 Enabled=yes Prio=0 Last Update=an hour ago
```

## Setup basic Export/Import (Outline)
> This is a outline how a workable ManageIQ depoyment could look like. Most people probably have something like this already running by the time they start running into the problems miq-flow addresses.

At this point you have a central repository with your Automate code and Customizations. You could just build some Automation (shell script, Ansible, Jenkins, ...) to import your code to PROD from the repository, there are even some more [scripts by the community](https://github.com/rhtconsulting/cfme-rhconsulting-scripts) to help you with that.

However this "Export from DEV > Commit to git > Import to PROD" workflow has one major problem (and some [smaller ones](reference.md#motivation)):  
There is only one DEV environment and you need to make sure no in-progess-code makes it in the export. 

# Develop Code
So far we have seen how to setup miq-flow on your DEV appliance, how we expect the code repository to look like and outlined a "Export from DEV > Commit to git > Import to PROD" workflow to get your code from DEV to PROD. **Let's start coding**

## Make a Change
Clone the repository to your local machine and create a feature branch to work on.  
Name your branch something similar to `feature-NAME-description`. Miq-Flow will use the `NAME` part of your branch name as identifier for the Automate domains it creates. Make sure it is something short and descriptive. More info [here](reference.md#naming-conventions).

```shell
$ git checkout -b feature-test-follow-user-guide
$ git push -u origin feature-test-follow-user-guide
```


Start making changes to your code,  commit and push them when you are ready to test the code in Automate.  
> miq-flow does not validate your domain directory. You have to take care of creating the required YAML files yourself, a little copy & paste usually does the trick.

## View your change
 `miq-flow branch inspect BRANCH-NAME` will print additional information about the changes you just made

```shell
# "test" is the identifier for that branch
# "feature-test-follow-user-guide" it the name of the branch
Feature: test on branch feature-test-follow-user-guide 
# commit-sha and message of the last commit to the feature branch
 Branch: 59c28d4d09fd1c9d5c3555e823ace75a90ee20b0: restore __namespace__.yaml
   Base: 1bf933c239e4b2e8202d2face868b99b76cbd30d: first commit

# files miq-flow is going to import
feat_test_buc
  automate/buc/Control/Email.class/__methods__/create_accounting_entry_on_vm_dedection.rb
feat_test_buc_lib
  automate/buc_lib/GenericObect/AccountingEntry.class/__methods__/create_accounting_entry.rb
```
## Test your change
`miq-flow deploy BRANCH-NAME --provider local`

That's the magic command to import the changes to the development appliance.  
The `--provider` option specifies, how miq-flow will talk to the appliance, `local` is the provider to use when running on a ManageIQ appliance.

<details>
<summary>Deploy Example</summary>

    $ miq-flow deploy feature-test-follow-user-guide --provider local
    I, [2019-02-04T18:00:22.353192 #11483]  INFO -- : Processing config file: /root/.miqflow.yaml
    I, [2019-02-04T18:00:22.354729 #11483]  INFO -- : Cloning git Repository from: https://github.com/ThomasBuchinger/miq-flow-example
    I, [2019-02-04T18:00:22.688855 #11483]  INFO -- : Deploying: feat_test_buc
    I, [2019-02-04T18:00:22.691433 #11483]  INFO -- : Importing with Appliance provider
    ** ManageIQ hammer-1, codename: Hammer
    Importing automate domain: buc from directory /tmp/miq_import_20190204-11483-4gwx7a/import/automate
    I, [2019-02-04T18:00:31.632118 #11483]  INFO -- : Deploying: feat_test_buc_lib
    I, [2019-02-04T18:00:31.634285 #11483]  INFO -- : Importing with Appliance provider
    ** ManageIQ hammer-1, codename: Hammer
    Importing automate domain: buc_lib from directory /tmp/miq_import_20190204-11483-4gwx7a/import/automate
</details>

---

**Let's review the changes in the ManageIQ WebUI**:

![Image of the Automate datastore with feature domains](domains_after_import.jpg?raw=true "Feature Domain Example")

As you can see, miq-flow created a feature domain called `feat_test_buc_lib` (`test` was the name of the branch and `buc_lib` the base domain name) and imported the shiny new `create_accounting_entry` method. 

> Because of ManageIQ's priority based lookup, the new method will **shadow** the original one, while the original code is used for everything that did not change.

Whenever Automate runs it will look for the code in the new feature domain. Most of the time it won't find it there and will fall back to your original base domain. But if Automate tries to run our `create_accounting_entry` method, the feature domain will take precedence and run the new code.  
In case you have multiple features to work on at the same time, ManageIQ will try all the feature domains, and fall back to the base domain. 

In the current form, there is no way for two features to modify the same method (unless you [do something else](developer.md#import-methods)), because there can only be one domain with the highest priority. 

## Repeat
Every time you change the code, you have to commit and push everything to the central git repository and rerun `miq-flow deploy`.

It is tempting to fix typos in the WebUI, make sure to do the same changes in your local repository too or the next code deployment will overwrite them. 

**Trigger import with CI**  
We recommend to integrate miq-flow in your CI system (jenkins, bamboo, gitlab) and trigger a `miq-flow deploy` for every push

> Keep in mind that miq-flow needs to run on the appliance.  

# Release the code
At this point you have your code on a separate feature branch, the branch is imported in ManageIQ in it's own feature domain, you successfully tested the code in Automate and everything is great. There is just one question left: **How do I get that code in production?**

This one seems pretty straight forward, make a Pull Request and merge it!  
The problem is, that if you move your code to production using the "Export from DEV > Commit to git > Import to PROD" workflow of ManageIQ, every export will overwrite any changes you made on `master` since the last *import* in DEV. 

There are a few Options to solve this problem, depending on your needs:

## Option 0: Manual Copy
Do nothing is actually an pretty good option here. When you are finished just copy everything from the feature domain to the base domain. The next automatic export will pick it up and import it to production

**Pros and Cons**
* Dead simple. Everything stays as it is.

## Option 1: Double down on git
The Automate code export contains YAML files with some additional metadata about a given namespace, class, instance or method. If you are comfortable creating those YAML files yourself you might want to double down on git and get rid of all the "Export from DEV > Commit to git > Import to PROD" workflow entirely. 

**Meta YAML files** have a very simple structure, however big classes and instances with many steps have very long meta YAMLs. Copy and paste is your friend here.

**Pros and Cons**
* Offers to be the most clean solution.
* Additional effort of editing YAML files by hand.
* The Export based workflow had a huge advantage. It kept Customizations (Buttons, Dialogs, ...) and the Automate code in sync. Now you have to either:
  * keep the Customization Export/Import and manage the dependency on the code yourself. Customizations tend to not change very often, so this is a good solution.
  * double double down on git and edit your Customizations in git too!
* The git import for domains can only handle one domain per repository. If you use multiple domains, you have to split the code into multiple repositories.
* You give up write access to your base domain, which might be desireable, since it prevents changes outside of git (and the history git provides).

### Lock down base domain
ManageIQ has a git import feature. If everything lives in git, there is no reason to keep the base domain as a normal domain. Instead you can make the base domain in DEV and PROD a git backed Automate domain. All the changes currently in development live in feature domains and are merged with Pull Requests.

* Navigate to `Automation > Automate > Import / Export`.
* Configure your git repository and choose `master` as the branch. 
* Check if the domain priority is still correct in `Automation > Automate > Explorer`.

Now you can refresh the base domain in the WebUI or via the [API](http://manageiq.org/docs/reference/latest/api/reference/automate_domains#refresh-from-source), whenever you are ready to update to the lastest and greatest version.

## Option 2a: Overwriting Export
A alternative option is to keep the "Export from DEV > Commit to git > Import to PROD" workflow in place and extend it to work with code contributed via PRs. There are a few things you need to do in order to pull this off:
* You need to periodically **import** your current `master` branch to DEV. This will prevent your baseline version to drift in DEV, PROD and `master`
* You need to base your export on the last import to DEV and merge the exported code with all PRs. 
* If a conflict occurs, you need to decide (automatically) which version takes precedence. The exported version or the version from the pull request.  

> The window to introduce conflicts depends on the fequency the job runs, however *during* the export you cannot work on the code in the WebUI. Once a day is manageable

### Review "Export from DEV > Commit to git > Import to PROD" workflow
A simplified version of your current scripts should look similar to the examples below.
> **Notice** that the import script tags the commit it imported with DEV or PROD

<details>
<summary>Simplified Import/Export scripts</summary>
<b>Export Script:</b>
<pre>
git clone https://github.com/ThomasBuchinger/miq-flow-tutorial /tmp/miq-flow-tutorial
rm -rf /tmp/miq-flow-tutorial/*

miqexport domain buc /tmp/miq-flow-tutorial/automate
rake evm:automate:export DOMAIN=buc EXPORT_DIR=/tmp/miq-flow-tutorial/automate

git add --all && git commit -m 'Automatic Export' && git push --all
</pre>

<b>Import Script:</b>
<pre>
git clone https://github.com/ThomasBuchinger/miq-flow-tutorial /tmp/miq-flow-tutorial

miqimport domain buc /tmp/miq-flow-tutorial/automate
rake evm:automate:import DOMAIN=buc IMPORT_DIR=/tmp/miq-flow-tutorial/automate ENABLED=true OVERWRITE=true

git tag $ENV_NAME master 
git push --all
</pre>
</details>

### Configure the Rebase 
<details>
<summary>Export script with PR support</summary>
<b>Export Script with PR support:</b>
<pre>
git clone https://github.com/ThomasBuchinger/miq-flow-tutorial /tmp/miq-flow-tutorial
cd /tmp/miq-flow-tutorial
git branch tmp_export $ENV_NAME
git checkout tmp_export

echo "=== Exporting from ManageIQ ==="
miqexport domain buc /tmp/miq-flow-tutorial/automate
rake evm:automate:export DOMAIN=buc EXPORT_DIR=/tmp/miq-flow-tutorial/automate
git add --all && git commit -m "Automatic Export"

echo "=== Rebase export onto master (i.e. pick up git changes) ==="
git rebase master --strategy recursive --strategy-option theirs

echo "=== Update master with the merged export and PR code ==="
git checkout master
git merge tmp_export
git branch -d tmp_export 

echo "=== Import updated Automate Code ==="
./my-manageiq-import.sh
</pre>
</details>

Let's dive in and see what the script does:
* `$ENV_NAME` is the tag created by the last import in that environment (DEV or PROD).
* First it creates and switches to a temporary branch `tmp_export`.  
  Note that the branch does not start on `master`, but on the tag that marks the last *import*.
* Next is the actual export of the Automate code and a commit to `tmp_export`.  
  Because the branch starts at `$ENV_NAME`, this commit only contains changes made directly in the base domain, instead of overwriting everything that was merged to `master` since the last import.
* Now we need to rebase the exported changes onto the lastest commit on `master`  
  We need to tell git how to resolve conflicts, since we cannot do it interactively. `theirs` means the exported version has precedence, `ours` means master takes precedence. See [git manual](https://git-scm.com/docs/git-rebase#git-rebase--Xltstrategy-optiongt).
* Some clean up: Commit the final version to `master` and remove the temporary branch. 
* Finally run the import script and re-import the export with the merged commit from `master`

> **Note**: This script omits some housekeeping to keep it simple. It will NOT work as it is.

## Option 2b: Miq-Flow-Exporter
This option fixes the conflict problem by introducing another tool. The basic idea is simple: Do a normal git merge, whenever there is a conflict, commit a prefered version to `master` (same as 2a), but instead of discarding the diff, collect the rejected diffs on a temporary branch. This results in a updated `master` branch and a "those are the changes I had to trash"-branch, which can be review by a human and either merged, discarded or resolved by hand.

[GitHub Project](https://github.com/ThomasBuchinger/miq-flow-export) 
> The level of polish in miq-flow-export is NOT the same as on the main project and is not planed to be integrated unless there is demand for it. At the moment is very early in development and will break stuff!
