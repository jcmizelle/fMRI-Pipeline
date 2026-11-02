#!/bin/bash

# export PATH=$PATH:/path/to/data/NEW_TOO/
# chmod a+x /path/to/data/NEW_TOO/get_cluster_loc

#fname='/path/to/data/NEW_TOO/FSLoutput/Level3/Subtraction/CvsI.gfeat/cope1.feat/stats/zstat1.nii.gz'
#cluster -i $fname -t 1.96 --connectivity=6 -n 8 --peakdist=10 --mm --olmax=/path/to/data/NEW_TOO/Zstat1--TEST
#fname2='/path/to/data/NEW_TOO/FSLoutput/Level3/Subtraction/CvsI.gfeat/cope1.feat/stats/zstat2.nii.gz'
#cluster -i $fname2 -t 1.96 --connectivity=26 -n 8 --peakdist=0 --mm --olmax=/path/to/data/NEW_TOO/Zstat2--TEST

# Prepare a random string to save temporary files
RND0=$(echo "$(date) ${IN} ${THR}" | md5sum )
RNDSTR=${RND0:0:12}

TESTFILE='/path/to/data/NEW_TOO/Zstat222222--TEST'

cat ${TESTFILE}

while read f1 f2 f3 f4 f5
    do
        echo $f1 $f2 $f3,$f4,$f5 
    done < $TESTFILE > tmp_${RNDSTR}.txt

cat tmp_${RNDSTR}.txt

while read f1 f2 f3
do 
echo $f1 $f2 $f3 >> $TESTFILE-LOCS.txt | ${FSLDIR}/bin/atlasquery -a "Talairach Daemon Labels" -c ${f3} | sed 's/<b>//g' | sed 's/<\/b><br>/\,/g' >> $TESTFILE-LOCS22222.txt
#awk 'print ${f1} - '  
#perl -lane 'unshift(@F,"${f1}");print join(",",@F)' inputfile
done < tmp_${RNDSTR}.txt

# Cleanup
#rm tmp_${RNDSTR}.txt
