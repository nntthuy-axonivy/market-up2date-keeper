#!/bin/bash
# reset all git changes in all directories

# loop through all folders
for d in */ ; do
    echo "Resetting $d"
    cd $d
    git reset --hard
    cd ..
done
