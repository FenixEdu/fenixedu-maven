DSI Releaser v0.1
=========

DSI Releaser is a script created to automate the process of releasing any Maven project, using Maven's [release plugin](http://maven.apache.org/maven-release/maven-release-plugin/), while following the conventions of [GitFlow](http://nvie.com/posts/a-successful-git-branching-model/).

Note that the script does NOT push anything into the upstream repositories, giving the user a chance to confirm that the release went as expected.

## Usage

To use DSI Releaser simply put `dsi-releaser.sh` in a folder in your `PATH`, and invoke the script.

## Example

```sh
jpc@arthas ~/workspace/bennu (release/1.2.0) $ dsi-releaser.sh 
=================================================================================
                             DSI - Releaser  v0.1
                         http://github.com/jcarvalho                             
=================================================================================
[DSI Releaser] Releasing bennu v1.2.0
[DSI Releaser] Enter the new development version (without SNAPSHOT, e.g. 1.4.2):
1.3.0
[DSI Releaser] Release version: 1.2.0
[DSI Releaser] Tag name: v1.2.0
[DSI Releaser] Development version: 1.3.0-SNAPSHOT
[DSI Releaser] Are you sure you want to continue? [y/n]
y
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Build Order:
[INFO] 
[INFO] Fenix Framework Backend-specific Features for Bennu
[INFO] Bennu Maven Plugin
[INFO] Bennu Project
[INFO] Bennu Framework Core
[INFO] Bennu File Support Plugin
[INFO] Bennu File Support
[INFO] Bennu Scheduler
[INFO] Bennu Scheduler UI
[INFO] Bennu Lucene Indexing
[INFO] Bennu Lucene UI
[INFO] Bennu Email Dispatching
[INFO] Bennu Web-Service Utils
[INFO] Bennu Framework
[INFO]                                                                         
[INFO] ------------------------------------------------------------------------
[INFO] Building Bennu Framework 1.2.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO] 
# Maven compilation
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 34.784s
[INFO] Finished at: Wed Jun 12 12:02:18 WEST 2013
[INFO] Final Memory: 15M/981M
[INFO] ------------------------------------------------------------------------
[DSI Releaser] Maven release plugin finished, starting Git-Flow magic
Removing bennu-backend-util/pom.xml.releaseBackup
Removing bennu-core/pom.xml.releaseBackup
Removing bennu-plugin/pom.xml.releaseBackup
Removing bennu-project/pom.xml.releaseBackup
Removing email-dispatch/pom.xml.releaseBackup
Removing file-support-plugin/pom.xml.releaseBackup
Removing file-support/pom.xml.releaseBackup
Removing lucene-indexing-plugin/pom.xml.releaseBackup
Removing lucene/pom.xml.releaseBackup
Removing pom.xml.releaseBackup
Removing release.properties
Removing scheduler-plugin/pom.xml.releaseBackup
Removing scheduler/pom.xml.releaseBackup
Removing web-service-utils/pom.xml.releaseBackup
Deleted tag 'v1.2.0' (was 171b870)
Switched to a new branch '__temp_branch_1.2.0'
[DSI Releaser] Created backup branch __temp_branch_1.2.0
Switched to branch 'release/1.2.0'
HEAD is now at e31d069 [maven-release-plugin] prepare release v1.2.0
Switched to branch 'master'
Merge made by the 'recursive' strategy.
 bennu-backend-util/pom.xml     |    2 +-
 bennu-core/pom.xml             |    2 +-
 bennu-plugin/pom.xml           |    2 +-
 bennu-project/pom.xml          |    4 ++--
 email-dispatch/pom.xml         |    2 +-
 file-support-plugin/pom.xml    |    2 +-
 file-support/pom.xml           |    2 +-
 lucene-indexing-plugin/pom.xml |    2 +-
 lucene/pom.xml                 |    2 +-
 pom.xml                        |    4 ++--
 scheduler-plugin/pom.xml       |    2 +-
 scheduler/pom.xml              |    2 +-
 web-service-utils/pom.xml      |    2 +-
 13 files changed, 15 insertions(+), 15 deletions(-)
[DSI Releaser] Merged into master
Switched to branch 'develop'
Merge made by the 'recursive' strategy.
 bennu-backend-util/pom.xml     |    2 +-
 bennu-core/pom.xml             |    2 +-
 bennu-plugin/pom.xml           |    2 +-
 bennu-project/pom.xml          |    4 ++--
 email-dispatch/pom.xml         |    2 +-
 file-support-plugin/pom.xml    |    2 +-
 file-support/pom.xml           |    2 +-
 lucene-indexing-plugin/pom.xml |    2 +-
 lucene/pom.xml                 |    2 +-
 pom.xml                        |    4 ++--
 scheduler-plugin/pom.xml       |    2 +-
 scheduler/pom.xml              |    2 +-
 web-service-utils/pom.xml      |    2 +-
 13 files changed, 15 insertions(+), 15 deletions(-)
[develop a496868] [maven-release-plugin] prepare for next development iteration
 13 files changed, 15 insertions(+), 15 deletions(-)
[DSI Releaser] Merged into develop
Deleted branch __temp_branch_1.2.0 (was e3ea2b3).
[DSI Releaser] Do you wish to delete the release branch (release/1.2.0)? [y/n]
y
Deleted branch release/1.2.0 (was e31d069).
Switched to branch 'master'
Your branch is ahead of 'upstream/master' by 4 commits.
[DSI Releaser] Do you wish to deploy the released version to nexus? [y/n]
n
[DSI Releaser] All done. You should now push the master/develop branches as well as the tags using:
[DSI Releaser] git push && git push <remote> v1.2.0
jpc@arthas ~/workspace/bennu (master)↑ $ 

```


## Requirements


In order for the release to be successful, there are some requirements:

 1. You must have the release branch checked out, with the correct version number (i.e. release/1.2.3 to release version 1.2.3)
 * You must be in the top-level folder, where the aggregator POM is (or the project's POM if it is a single-module repository)
 * You must have the working directory clean (i.e. no uncommitted changes)
 * The tag for the release must not exist
 * Your `master/develop` branches must be up-to-date with your upstream remote, otherwise you WILL get conflicts and your branches will diverge
 * Your POMs must be in a `SNAPSHOT` version

## Features

 * Performing several sanity checks, to ensure the environment fulfills the requirements (not all requirements are enforced in the current version).
 * Invoking `maven-release-plugin`
 * Merging into the `master/develop` branches
 * Creating the SNAPSHOT-bump commit in `develop`
 * Creating the release tag from the `master` branch
 * Deleting the release branch
 * Deploying the released version to Nexus
  
## Future Development

 * Correctly abort the release if there is a compilation error in Maven
 * Check that the local `master/develop` branches are up-to-date
 