#!/bin/bash
#
# cp-file.sh
#
# fake 'editor' to copy a file into place

# Assume that the other pieces we need are in this script's directory
REBASE_HOME="$(readlink -f $(dirname $0))"

# Default is to copy the rebase 'todo' script
SRC_FILE="$REBASE_TODO"


if test "$GIT_REBASE_COMMAND" = reword; then
    echo -n "reword: "
    SRC_FILE=$REBASE_HOME/patches/$GIT_SHA1_SHORT.reword
fi




test -f "$SRC_FILE" || exit 1
echo cp -f $SRC_FILE $1
cp -f $SRC_FILE $1
