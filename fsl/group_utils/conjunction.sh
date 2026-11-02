#!/bin/bash

# export PATH=$PATH:/path/to/data/AU/
# chmod a+x /path/to/data/AU/AU_batch
# chmod a+x /path/to/data/LinuxScripts/easythresh_conj

# Specifically, let's say you want to conjoin: zstat1 zstat2 zstat3 zstat4.  First, execute the conjunction combination (i.e. minimum operation) on K-1=3 of them:
zstat1='/path/to/data/AU/FSLoutput/Level3/Pre_Cope1.gfeat/cope1.feat/stats/zstat1.nii.gz'
zstat2='/path/to/data/AU/FSLoutput/Level3/Pre_Cope2.gfeat/cope1.feat/stats/zstat1.nii.gz'
zstat3='/path/to/data/AU/FSLoutput/Level3/Pre_Cope3.gfeat/cope1.feat/stats/zstat1.nii.gz'
zstat4='/path/to/data/AU/FSLoutput/Level3/Pre_Cope4.gfeat/cope1.feat/stats/zstat1.nii.gz'

fslmaths ${zstat1} -min ${zstat2} ${zstat3} /path/to/data/AU/Conjunction/pre_zstat_min_1-3

# Now call easythresh_conj with zstat_min_1-3 and the last one, zstat4.  For uncorrected stats:

/path/to/data/LinuxScripts/easythresh_conj /path/to/data/AU/Conjunction/pre_zstat_min_1-3.nii.gz ${zstat3} 1.64 /path/to/data/AU/FSLoutput/Level3/Pre_Cope1.gfeat/cope1.feat/example_func.nii.gz pre_nii

# or with corrected stats

/path/to/data/LinuxScripts/easythresh_conj zstat1_min_1-3 ${zstat4} 2.3 0.01 /path/to/data/AU/FSLoutput/Level3/Pre_Cope1.gfeat/cope1.feat/example_func.nii.gz pre.nii

# or, more accurately, using a smoothness estimate from a related FEAT directory

/path/to/data/LinuxScripts/easythresh_conj -s DIR.feat/stats/smoothness /path/to/data/AU/Conjunction/zstat_min_1-3.nii.gz ${zstat4} 2.3 0.01 /path/to/data/AU/FSLoutput/Level3/Pre_Cope1.gfeat/cope1.feat/example_func.nii.gz pre.nii



cope4='/path/to/data/AU/FSLoutput/Level2/AU_007_Pre.gfeat/cope4.feat/stats/cope1.nii.gz'
cope1='/path/to/data/AU/FSLoutput/Level2/AU_007_Pre.gfeat/cope1.feat/stats/cope1.nii.gz'
cope2='/path/to/data/AU/FSLoutput/Level2/AU_007_Pre.gfeat/cope2.feat/stats/cope1.nii.gz'
cope3='/path/to/data/AU/FSLoutput/Level2/AU_007_Pre.gfeat/cope3.feat/stats/cope1.nii.gz'

fslmaths ${cope1} -sub ${cope4} /path/to/data/AU/Subtraction/pre/sub7_cope1.nii.gz
fslmaths ${cope2} -sub ${cope4} /path/to/data/AU/Subtraction/pre/sub7_cope2.nii.gz
fslmaths ${cope3} -sub ${cope4} /path/to/data/AU/Subtraction/pre/sub7_cope3.nii.gz

cope4='/path/to/data/AU/FSLoutput/Level2/AU_007_Post.gfeat/cope4.feat/stats/cope1.nii.gz'
cope1='/path/to/data/AU/FSLoutput/Level2/AU_007_Post.gfeat/cope1.feat/stats/cope1.nii.gz'
cope2='/path/to/data/AU/FSLoutput/Level2/AU_007_Post.gfeat/cope2.feat/stats/cope1.nii.gz'
cope3='/path/to/data/AU/FSLoutput/Level2/AU_007_Post.gfeat/cope3.feat/stats/cope1.nii.gz'

fslmaths ${cope1} -sub ${cope4} /path/to/data/AU/Subtraction/post/sub7_cope1.nii.gz
fslmaths ${cope2} -sub ${cope4} /path/to/data/AU/Subtraction/post/sub7_cope2.nii.gz
fslmaths ${cope3} -sub ${cope4} /path/to/data/AU/Subtraction/post/sub7_cope3.nii.gz
