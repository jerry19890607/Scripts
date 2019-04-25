#!/bin/sh
# Script to sign the PRJ files using MD5 Check sum
update_file() 
{
		file=$1
		echo -n "Signing $file..."
	        checksum=`md5sum $file | awk '{print $1}'`
        	echo $comment$checksum > temp.PRJ
	        cat $file >> temp.PRJ
        	mv temp.PRJ $file
                echo DONE!!!
}

if [ $# -eq 0 ]; then
  echo -e "Usage: signprj.sh PRJFiles\n"
fi

comment="# Created and Signed by MDS : "
for file in $*
do
	if [ -a $file ]; 
	then
		update_file $file
	else
		echo 
		echo $file does not exist!!!
		echo
	fi
done
