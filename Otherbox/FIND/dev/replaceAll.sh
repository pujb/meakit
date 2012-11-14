#! /bin/bash
# Replaces first argument with second in all m-files recursively.
# Careful with arguments that have shell specific characters. For
# instance, to replace 'myTag' including the quotes, pass the string
# with double quotes: ./replaceAll.sh "'myTag'" newString
files=`find -type f -name '*.m'`
for f in $files
do 
  counts=`grep -c "$1" $f`
  if [ $counts -ne 0 ]
  then
      sed "s/$1/$2/g" $f > $f.tmp && mv $f.tmp $f && echo "replaced $counts occurrence(s) of $1 with $2 in file $f"
  fi
done