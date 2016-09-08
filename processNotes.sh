#!/bin/bash
# note: must have bash 4 or greater to use this script
# associative arrays, yaknow

rootdir=$1 # notes directory
echo $rootdir
temp=$rootdir/temp #temp dir where ai files will be copied and processed if updated or new
mkdir -p $temp             # if $temp doesn't exist, create it
mkdir -p $rootdir/partial  # if partial doesn't exist, create it
mkdir -p $rootdir/archive  # if archive doesn't exist, create it
echo $0
cd ${0%/*} # make the directory this script is in the current working directory
currentdir=$(pwd)
# currentdir=$rootdir

# Create file lists ----------------------------------
flist=$rootdir/flist.txt
flistOld=$rootdir/flistOld.txt
if [ ! -e "$flist" ] ; then
    touch "$flist"
fi
mv $flist $flistOld # save old file list
touch $flist # create new empty file list
for f in $rootdir/*.ai
do
  fn1=$f
  fdate=$(stat -f "%Sm" -t "%Y%m%d%H%M%S" $fn1) # date/time modified
  fn2=${fn1%.*}       # strip extension
  fname="${fn2##*/}"  # strip path
  printf '%s\n%s\n' $fname $fdate >> $flist
done

# Read new file list ----------------------------------
echo "---------------------"
declare -A fNew # declare fNew an associative array
i=0; j=0; k=0
while read line
do
    lineData=$line
    # echo "Text read from file | $lineData"
    if [ $((i%2)) -eq 0 ]
    then # even
        # printf 'i is even\n' ''
        fnames=$lineData
    else # odd
        # printf 'i is odd\n' ''
        fdates=$lineData
        fNew[$fnames]=$fdates
    fi
    let i++
done < $flist
N=$i
printf "new file list:\n"
for i in ${!fNew[@]}
do
  echo "key  : $i"
  echo "value: ${fNew[$i]}"
done

# Read old file list ----------------------------------
echo "---------------------"
declare -A fOld # declare fOld an associative array
i=0; j=0; k=0
while read line
do
    lineData=$line
    # echo "Text read from file | $lineData"
    if [ $((i%2)) -eq 0 ]
    then # even
        # printf 'i is even\n' ''
        fnames=$lineData
    else # odd
        # printf 'i is odd\n' ''
        fdates=$lineData
        fOld[$fnames]=$fdates
    fi
    let i++
done < $flistOld
N=$i
printf "old file list:\n"
for i in ${!fOld[@]}
do
  echo "key  : $i"
  echo "value: ${fOld[$i]}"
done

# Compare and copy modified files to $temp accordingly --------------
echo "---------------------"
n=$(( $N - 1 ))
for i in ${!fNew[@]} # for each key
do
  key=$i
  valNew=${fNew[$i]}
  valOld=${fOld[$i]}
  if [ -n "$valOld" ] # if $valOld is not an empty string (i.e. if it matches an old key)
  then
    printf "%s.ai has been here ...\n" $key
    if (( $valNew != $valOld )) # if date modified has changed
    then # copy ai file to temp directory
      printf "\--> tand it changed!\n\t--> Copying to $temp\n"
      cp  -f -p "$rootdir/$key.ai" "$temp/"
    else
      printf "\t--> and it hasn't changed.\n"
    fi
  else # copy ai file to temp directory
    printf "%s.ai is a n00b!\n\t--> Copying to $temp\n" $key
    cp -f -p "$rootdir/$key.ai" "$temp/"
  fi
done

# Save pdf files with Adobe javascript mySaveAsArchivePDFs.jsx -------------------
# had to use an applescript as a wrapper
echo "---------------------"
if find $temp -name "*.ai" -maxdepth 1 | read
then 
  echo "Processing and creating partial and archive copies ..."
  osascript $currentdir/callScripts.scpt $rootdir
else
  echo "No temp files to process ..."
fi
printf "\t---> done.\n"

# Delete $temp files ----------------------------------------------
echo "---------------------"
if find $temp -name "*.ai" -maxdepth 1 | read
then
  echo "Deleting temp files ..."
  rm $temp/*.ai
else
    echo "No temp files to delete ..."
fi
printf "\t--> done.\n" ''
