#!/bin/bash
#
# Run git rebase --interactive, but without interaction

# Put a file 'rebase-script.txt' in this directory containing the
# git-rebase--interactive script, and set the below settings.

# Run the script with "-l" for a log

#############################################################
# settings

# set branch and upstream commits
orig_head=rtos-integration-preview3-clean-v2.5_branch-merge-ub
upstream=9d7fbdd

# pretty format for git log --graph
pretty='--pretty=format:"%h [%an] %s"'

#############################################################
# set up variables

# for 'git log' output to include the parent commit but not
# grandparents
exclude_upstream_parent="$(git rev-list -1 --parents $upstream | \
	awk '{l=""; for (n=2;n <= NF;n++) l=l " ^" $n; print l}')"

# Assume that the other pieces we need are in this script's directory
REBASE_HOME="$(dirname $0)"

# cp-todo.sh is a fake editor that simply copies $REBASE_TODO
export EDITOR="$REBASE_HOME/cp-todo.sh"

# The interactive rebase script, used by cp-todo.sh
export REBASE_TODO="$REBASE_HOME/rebase-script.txt"


#############################################################
# run the rebase

rebase() {
    # abort any rebase in progress
    git rebase --abort 2>/dev/null;

    # exit if the following fail
    set -e

    # check out a clean copy of the branch to rebase
    git checkout $orig_head 2>/dev/null && git reset --hard

    # execute the rebase
    git rebase -i -p $upstream

    # now let the user sort out all the pieces.  :P
}


#############################################################
# run git log

log() {
    git log $exclude_upstream_parent HEAD --graph "$pretty"
}


#############################################################
# main program

case "$1" in
    '')
	rebase ;;
    '-l')
	log; echo ;;
esac
