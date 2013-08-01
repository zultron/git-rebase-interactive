#!/bin/bash

# fake 'editor' to copy a file into place
test -s "$REBASE_TODO" || exit 1
cp -f $REBASE_TODO $1
