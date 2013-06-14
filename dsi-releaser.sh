#/bin/bash

function println() {
    echo "[DSI Releaser]" $@
}

SCRIPT_VERSION=v0.1.2
UPDATES_URL='https://raw.github.com/ist-dsi/ist-dsi-maven/dsi-releaser/dsi-releaser.sh'

ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
RELEASE_VERSION=$(git rev-parse --abbrev-ref HEAD | sed 's/\// /g' | awk ' { print $NF } ')
TAG_NAME="v$RELEASE_VERSION"
BACKUP_BRANCH="__temp_branch_$RELEASE_VERSION"
CURR_BRANCH=$(git rev-parse --abbrev-ref HEAD)


function printWelcome() {

    REPO_NAME=$(basename `git rev-parse --show-toplevel`)

    echo "================================================================================="
    echo "                            DSI - Releaser  $SCRIPT_VERSION                     "
    echo "                         http://github.com/jcarvalho                             "
    echo "================================================================================="
    println "Releasing $REPO_NAME v$RELEASE_VERSION"
}

function checkForUpdates() {
    println "Checking for updates..."

    LATEST_VERSION=$(curl --silent $UPDATES_URL  | grep ^SCRIPT_VERSION | sed 's/=/ /g' | awk ' { print $NF } ')

    # TODO: Check if version is greater, not different
    if [[ $LATEST_VERSION != $SCRIPT_VERSION ]];
        then
        println "An update to DSI Releaser is available ($LATEST_VERSION). Do you wish to proceed with the release? [y/n]"

        read PROCEED

        if [[ $PROCEED != 'y' ]];
            then
            println "Aborting..."
            exit -1
        fi
    else 
        println "DSI Releaser is up-to-date"
    fi
}

function performChecks() {
    if [[ ! $RELEASE_VERSION =~ [0-9]+.[0-9]+.[0-9]+ ]];
        then
        println "Not in a release branch, aborting!"
        exit -1
    fi
    if [[ ! $(git status) =~ "working directory clean" ]];
        then
        println "You have uncommitted changes. Please commit them before releasing!"
        exit -1
    fi

    if git show-ref --tags --quiet --verify "refs/tags/v$RELEASE_VERSION";
        then
        println "A tag with name v$RELEASE_VERSION already exists!"
        exit -1
    fi

    if [[ ! -f pom.xml ]];
        then
        println "No POM file found in the current directory"
        exit -1
    fi
}

function checkBranchesUpToDate() {

    println "Fetching from remotes"
    git fetch --all -p > /dev/null

    println "Remotes fetched, ensuring local branches are up-to-date"

    checkBranchConflict master
    checkBranchConflict develop

    checkBranch master
    checkBranch develop
    checkBranch $ORIGINAL_BRANCH

    git checkout $ORIGINAL_BRANCH &> /dev/null
}

function checkBranchConflict() {
    if [[ $(git branch -a | grep -v remotes | grep $1 | wc -l) = "0" ]];
        then
        # Branch is not local, let's see if there are any conflicts...
        if [[ $(git branch -a | grep remotes | grep $1\$ | wc -l) != 1 ]];
            then
            println "Error! Branch $1 is not checked out and is present in multiple remotes!"
            exit -1
        fi
    fi
}

function checkBranch() {
    git checkout $1 &> /dev/null
    STATUS=$(git status)
    if [[ $STATUS =~ "Your branch is" ]];
        then
        println "Error. Branch $1 is not in sync with remote!"
        exit -1
    fi
    if [[ $STATUS =~ "Your branch and" ]];
        then
        println "Error. Branch $1 is not in sync with remote!"
        exit -1
    fi
    println "Branch $1 is up-to-date"
}

function release() {

    println "Enter the new development version (without SNAPSHOT, e.g. 1.4.2): " 

    read DEVELOP

    if [[ ! $DEVELOP =~ [0-9]+.[0-9]+.[0-9]+ ]];
        then
        println "ERROR: Version must be in the form X.Y.Z"
        exit
    fi

    println "Release version: $RELEASE_VERSION"
    println "Tag name: $TAG_NAME"
    println "Development version: $DEVELOP-SNAPSHOT"
    println "Are you sure you want to continue? [y/n]"

    read OPTION

    if [[ $OPTION != 'y' ]];
        then
        println "Aborting..."
        exit
    fi

    mvn release:prepare -B \
                        -Dtag=$TAG_NAME \
                        -DreleaseVersion=$RELEASE_VERSION \
                        -DdevelopmentVersion=$DEVELOP-SNAPSHOT \
                        -DscmCommentPrefix="[DSI Releaser] "

    if [[ $? -ne 0 ]];
        then
        git checkout .
        git clean -df
        println "Maven compilation failure. Aborting..."
        exit -1
    fi

    println "Maven release plugin finished, starting Git-Flow magic"

    git clean -df &> /dev/null

    git tag -d $TAG_NAME &> /dev/null

    git checkout -b $BACKUP_BRANCH &> /dev/null
    println "Created backup branch $BACKUP_BRANCH"

    git checkout $ORIGINAL_BRANCH &> /dev/null
    git reset --hard HEAD~1 &> /dev/null

    println "Merging into master"

    git checkout master &> /dev/null
    git merge --no-ff $ORIGINAL_BRANCH

    if [[ $? -ne 0 ]]; then
        println "Merge to master had conflicts. Resolve the conflicts manually," 
        println "then use 'git add <file>' to mark the conflict as resolved. Run 'exit' to resume the release."
        bash
        git commit
    fi

    git tag $TAG_NAME

    println "Merged into master"

    println "Merging into develop"

    git checkout develop  &> /dev/null
    git merge --no-ff $ORIGINAL_BRANCH

    if [[ $? -ne 0 ]]; then
        println "Merge to develop had conflicts. Resolve the conflicts manually," 
        println "then use 'git add <file>' to mark the conflict as resolved. Run 'exit' to resume the release."
        bash
        git commit
    fi

    git cherry-pick $BACKUP_BRANCH


    if [[ $? -ne 0 ]]; then
        println "Cherry-Pick to develop had conflicts. Resolve the conflicts manually," 
        println "then use 'git add <file>' to mark the conflict as resolved. Run 'exit' to resume the release."
        bash
        git commit
    fi

    println "Merged into develop"
    git branch -D $BACKUP_BRANCH &> /dev/null

    println "Do you wish to delete the release branch ($ORIGINAL_BRANCH)? [y/n]"

    read REMOVE_BRANCH

    if [[ $REMOVE_BRANCH == 'y' ]]
        then
        git branch -D $ORIGINAL_BRANCH
    fi

    git checkout master &> /dev/null

    println "Do you wish to deploy the released version to nexus? [y/n]"

    read DEPLOY_TO_NEXUS

    if [[ $DEPLOY_TO_NEXUS == 'y' ]] 
        then
        mvn clean source:jar deploy
    fi

    println "All done. You should now push the master/develop branches as well as the tags using: "
    println "       git push && git push <remote> $TAG_NAME"

}

printWelcome
checkForUpdates
performChecks
checkBranchesUpToDate
release
