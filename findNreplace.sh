#!/bin/bash

# Finds $1 and replaces with $2 in all valid files
# Verifies number of replacements on completion

for filename in ${@:3}
do
  # Record line nos of instances of $1
  grep -n $1 $filename | cut -f1 -d: > grepResult1

  # If instances of $1 are found
  if [ -s grepResult1 ]; then
    # Replace all instances of $1 with $2
    sed "s/$1/$2/g" $filename > dummyfile

    # Record line nos of instances of $2
    grep -n $2 dummyfile | cut -f1 -d: > grepResult2

    # Count number of differences between replacements
    ndiffs="$(diff -U 0 grepResult1 grepResult2 | grep ^@ | wc -l)"

    # Replace if line numbers match
    if [ "${ndiffs}" -ne 0 ]; then
      echo REPLACE FAILED "${ndiffs}" times in "$filename" in lines:
      diff -U 0 grepResult1 grepResult2
    else
      # Overwrite 
      mv dummyfile "$filename"
      echo REPLACE SUCCESS in "$filename"
    fi

    # else # IGNORE
    # echo "No instances found of $1 in $filename"
  fi
done

# Remove grepResult files
rm -f grepResult?
