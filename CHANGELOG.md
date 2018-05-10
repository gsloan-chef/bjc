# Change Log

## 4.6.2

**Bugfixes**
- Remove all references to Compliance from ARM templates

## 4.6.1

**Features**
- Renable Azure builds

## 4.6.0

**Breaking Change**
- Shell and powershell launchers now require an additional argument for the cloud platform.  This will break any scripts based on the prior argument sets.

**Features**
- Add support for multiple cloud platforms to shell and powershell launchers
- Ability to launch Azure-based demo environments from shell and powershell launchers

**Requirements**
- Launching Azure demos requires Azure CLI 2.0+ to be installed on local workstation

## 4.5.6

**Feature:**
- Drop a file on the desktop with DCA commands for the demonstrator to quickly reference.

## 4.5.5

**Features**
- Clarify the usage statement for `build_demo.sh`, the cloud provider is part of the version

## 4.5.4

**Feature:**
- Add PowerShell launch script `./bin/build_demo.ps1`. Launch demos on Windows the same way as the Mac!

## 4.5.3

**Bugfixes**
- Add required X-Application tag to build script

## 4.5.2

**Features**
- Updated bjc_workstation cookbook to define the workstation's startup script as an attribute, allowing easier custom builds.

**Bugfixes**
- Updated the audit-wrapper cookbook to use the 'workstation-1' user instead of 'delivery'.

- Updated bjc_infranodes cookbook with guards to only execute linux-specific resource if `node['platform']` isn't 'windows'

## 4.5.1

**Bugfixes**
- Update build cookbook to expect 10 AMIs instead of 11, now that Compliance is not being built.

## 4.5.0

- Removed the Compliance Server from the demo stack.

## 4.4.6

**Bugfixes**
- Update verification logic to only validate version bump in wombat.yml in Verify. Change will have already been merged to master when Unit is re-run at Build.

## 4.4.5
- Update build cookbook to validate that CHANGELOG.md and demo version have been changed during Verify per [\#676](https://github.com/chef-cft/bjc/issues/676)

## 4.4.4
- Allows RDP to be reached over port 443 on workstation per [\#422](https://github.com/chef-cft/bjc/issues/422)

## 4.4.3
- Functional tests executed on build nodes in promotion pipeline
- Allow inbound WinRM in CloudFormation template

## 4.4.2
- Updated tagging standards for Stacks & AMIs

## 4.4.1
- MVP release of Azure Cloud Migration startup script

## 4.3.12
- Updated partner accounts
- Removed windows 2012-r2 workstation support
- Removed "visibility" bookmark from Chrome

## 4.3.11
- Updated partner accounts for auto-publish.

## 4.3.10
- Updates to community cookbooks metadata to pull in habitat
- Updates to Powershell functions to enable adding roles to nodes

## 4.3.9
- Adds audit-wrapper cookbook to the Chef Server
- MVP release of AMI tagging
- Updated templates to only export AMIs on pipeline builds
- Updates Automate to 1.8.3

## 4.3.7
- Adds the audit-wrapper cookbook to the repo
- Uploads additional roles and cookboks to the Chef Server
- Conditional build behavior removed from build cookbook. All changes will now result in a full stack build.
- ChefDK 2.x update on workstation
- Wombat gem version pinning update to support ChefDK 2

## 4.3.2

**Updates:**
- `Start_CM.ps1` updated to auto-launch initial EC2 instance. Speeds up and simplifies demo startup.

## 4.3.1

**Updates:**
- Powershell functions will now output the un-abstracted command they ran when complete.

**Bugfixes:**
- Fixes an issue in the build cookbook where acceptance de-provisioning fails if executed on a centos builder. Confining configs to ubuntu builders for that stage.

## 4.3.0

**Updates:**
- Cloud Migration MVP! New minor version bump.
- Added Start_CM.ps1 startup script to launch cloud demo.
- Added new powershell functions for CM demo

**Powershell Aliases:**
- DCA-Bootstrap-SSH $Hostname $Environment $Cookbook $Recipe
  - Bootstraps a node via SSH to the specified environment and add $Cookbook::$Recipe to its run list.
- DCA-AWS-Create $Environment $Cookbook $Recipe
  - (AWS Only) Creates a new EC2 instance, and bootstraps into specified environment with associated recipe in its run list.
- DCA-Nuke-Automate
  - Deletes all data from Automate Server. Keeps installed profiles, creds, and nodes. Just removes converge/scan history.

**Breaking Changes:**
- The `Update-RunLists` and `DCA-Update-Nodes` functions now require a cookbook to be specified. Previously only required recipe, as the `dca_demo` cookbook was hardcoded. Script will be updated with promotion.


## 4.2.3

**Updates:**
- Added new cookbook/profile for Cloud Migration demo to chef server and workstation.

## 4.2.2

**Updates:**
- Added assurity partner account to accounts.json per [\#642](https://github.com/chef-cft/bjc/pull/642)
- Added dca_audit_baseline and dca_hardening_linux to BJC workstation local checkouts.

## 4.2.0

**Updates:**
- Added MVP Windows wrapper profile to repo, and updated workstation recipe to upload.
- Moved initial CCR to user_data in the cfn json. The start_demo script now waits for machines to register, and runs a second CCR via push jobs.
- Minor release due to change in default instance types and launch behavior. Should be non-impacting to demo workflows.

**Closed Issues:**
- [\#632](https://github.com/chef-cft/bjc/issues/632) - *enhancement* - Updated json template to use m4/c4 instances instead of m3/c3. Should slightly improve performance, and reduce instance costs.
- [\#634]((https://github.com/chef-cft/bjc/issues/634) - *enhancement* - Updated DCA launch scripts to speed up demo prep. No longer spins up TK by default (can be turned on by uncommenting in Start_DCA), and makes use of powershell parallelization to speed up re-bootstrap of nodes.

## 4.1.0

**Closed Issues:**
- [\#627](https://github.com/chef-cft/bjc/issues/627) - *enhancement* - Added CHANGELOG.md to project to better track development history.
- [\#625](https://github.com/chef-cft/bjc/issues/625) - *bug* - Unexpected audit errors persist after DCA_Correct script. Solved by introducing version pinnings to wrapper profile.
- [\#618](https://github.com/chef-cft/bjc/issues/618) - *enhancement* - Added inspec wrapper profile to /profiles directory in project, and archive/upload in Start_DCA script. Replaces previous implementation of pulling a static profile via cookbook files.
- [\#628](https://github.com/chef-cft/bjc/issues/627) - *enhancement* - Added powershell function to combine the functionality of Update-RunLists and Invoke-ChefClient to streamline demonstrations.
