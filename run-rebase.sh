#!/bin/bash
#
# Run git rebase --interactive, but without interaction

# Put a file 'rebase-script.txt' in this directory containing the
# git-rebase--interactive script, and set the below settings.

# Options:
# -l:  print a graph of $upstream..HEAD
# -L:  print a graph of $upstream..$orig_head
# -e:  manually edit the todo list instead of using rebase-script.txt

#############################################################
# settings

# set branch and upstream commits
orig_head=linuxcnc/unified-build-candidate-0
#orig_head=rtos-integration-preview3-clean-v2.5_branch-merge-ub
upstream=9d7fbdd

# a name for the new branch
new_branch=ubc0-rebase

# pretty format for git log --graph
pretty='--pretty=format:"%h [%an] %s"'

#############################################################
# set up variables

# for 'git log' output to include the parent commit but not
# grandparents
exclude_upstream_parent="$(git rev-list -1 --parents $upstream | \
	awk '{l=""; for (n=2;n <= NF;n++) l=l " ^" $n; print l}')"

# Assume that the other pieces we need are in this script's directory
REBASE_HOME="$(readlink -f $(dirname $0))"

# Add $REBASE_HOME to git's exec-path
export GIT_EXEC_PATH="$REBASE_HOME:$(git --exec-path)"

# if -e is absent, use rebase-script.txt as input to the merge
if test "$1" != -e; then
    # cp-todo.sh is a fake editor that simply copies $REBASE_TODO
    export EDITOR="$REBASE_HOME/cp-file.sh"

    # The interactive rebase script, used by cp-todo.sh
    export REBASE_TODO="$REBASE_HOME/rebase-script.txt"
else
    # remove -e from args
    shift
fi

excludes="$(echo $GIT_REBASE_EXCLUDE | \
	awk '{ l = "";for (i=1;i<=NF;i++) l=l " ^" $i;print l}')"

# Exclude any commits from master
# This removes commits that don't need to be rebased
export GIT_REBASE_EXCLUDE=master


#############################################################
# run the rebase

rebase() {
    # abort any rebase in progress
    git rebase --abort 2>/dev/null
    rm -fr ".git/rebase-merge"

    # git rid of any old rebase branch
    git branch -M $new_branch $new_branch-$$ 2>/dev/null && moved_branch=true

    # exit if the following fail
    set -e

    # check out a clean copy of the branch to rebase
    git checkout -b $new_branch $orig_head 2>/dev/null && git reset --hard

    # remove old rebase branch
    $moved_branch && git branch -D $new_branch-$$ || true

    # execute the rebase
    git rebase -i -p $upstream

    # now let the user sort out all the pieces.  :P
}


#############################################################
# run git log

#git log ^master remotes/linuxcnc/unified-build-candidate-0 --graph \
#    --pretty=format:"%h [%an] %s"
log() {
    case "$1" in
	'-l')
	    local tip=HEAD ;;
	'-L')
	    local tip=$orig_head ;;
    esac
    git log $exclude_upstream_parent $excludes $tip --graph "$pretty"
}


#############################################################
# main program

case "$1" in
    '')
	rebase ;;
    '-l'|'-L')
	log $@; echo ;;
esac
