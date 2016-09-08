#!/bin/bash

printf -- '---------------------*** Process all notes ***---------------------\n' ""

cd ${0%/*} # make the directory this script is in the current working directory
rootdir=$(pwd)

# Directories ----------

sourceRoot=$rootdir
destRoot=$rootdir/courses
coursesArray=(
  me345_2016F
  me316_2016F
)

coursesIndices=`seq 0 $(( ${#coursesArray[@]} - 1 ))`

# Process notes ------------
for i in $coursesIndices; do
  printf -- '---------------------Processing notes---------------------\nfrom: %s\n' "${coursesArray[$i]}"
  bash $rootdir/processNotes.sh $sourceRoot/${coursesArray[$i]}
done
printf -- '\t--> done.\n' ''

# read dun # uncomment this to leave the terminal window open ... for debugging purposes