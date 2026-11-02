#!/bin/bash

# export PATH=$PATH:/path/to/data/AU/
# chmod a+x /path/to/data/AU/AU_batch

/usr/local/fsl/bin/cluster -i thresh_zstat1 -c stats/cope1 -t 2.3 -p 0.05 -d 0.0779672 --volume=64713 --othresh=thresh_zstat1 -o cluster_mask_zstat1 --connectivity=26  --olmax=lmax_zstat1.txt > cluster_zstat1.txt

/usr/local/fsl/bin/cluster2html . cluster_zstat1 

/usr/local/fsl/bin/cluster -i thresh_zstat2 -c stats/cope2 -t 2.3 -p 0.05 -d 0.0779672 --volume=64713 --othresh=thresh_zstat2 -o cluster_mask_zstat2 --connectivity=26  --olmax=lmax_zstat2.txt > cluster_zstat2.txt

/usr/local/fsl/bin/cluster2html . cluster_zstat2 

