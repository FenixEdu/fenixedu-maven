#/bin/bash

function println() {
    echo "[DSI Releaser]" $@
}

ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
RELEASE_VERSION=$(git rev-parse --abbrev-ref HEAD | sed 's/\// /g' | awk ' { print $NF } ')
TAG_NAME="v$RELEASE_VERSION"
BACKUP_BRANCH="__temp_branch_$RELEASE_VERSION"
CURR_BRANCH=$(git rev-parse --abbrev-ref HEAD)


function printWelcome() {

    REPO_NAME=$(basename `git rev-parse --show-toplevel`)

    echo "================================================================================="
    echo "                             DSI - Releaser  v0.1                                "
    echo "                         http://github.com/jcarvalho                             "
    echo "================================================================================="
    println "Releasing $REPO_NAME v$RELEASE_VERSION"
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

    git clean -df

    git tag -d $TAG_NAME

    git checkout -b $BACKUP_BRANCH
    println "Created backup branch $BACKUP_BRANCH"

    git checkout $ORIGINAL_BRANCH
    git reset --hard HEAD~1

    git checkout master
    git merge --no-ff $ORIGINAL_BRANCH

    if [[ $? -ne 0 ]]; then
        println "Merge to master had conflicts. Resolve the conflicts manually," 
        println "then use 'git add <file>' to mark the conflict as resolved. Run 'exit' to resume the release."
        bash
        git commit
    fi

    git tag $TAG_NAME

    println "Merged into master"

    git checkout develop
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
    git branch -D $BACKUP_BRANCH

    println "Do you wish to delete the release branch ($ORIGINAL_BRANCH)? [y/n]"

    read REMOVE_BRANCH

    if [[ $REMOVE_BRANCH == 'y' ]]
        then
        git branch -D $ORIGINAL_BRANCH
    fi

    git checkout master

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
performChecks
release
