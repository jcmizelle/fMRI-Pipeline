#!/bin/bash
#
# So far (5/16/2012) this first section seems to work with linear registrations...
#
# Group data mask in Standard space  ---> individual subject space
#
# Seed ROI selection and time series extraction:
#
# Start loops:
for c in CONDS   ; 
do

for s in SUBJ   ;
do 

# Group condition of interest:
# 
DATADIR=/path/to/data/SD/Level2/Paired/IvsNH.gfeat
SUBDATADIR=/path/to/data/SD/FSLoutput/SD_001_20110701/Run1.feat
REGDIR=/path/to/data/SD/FSLoutput/SD_001_20110701/Run1.feat/reg
PPIdir=/path/to/data/SD/FSLoutput/PPI/IvsNH/SD_001_20110701/Run1
mkdir -p $PPIdir

# Move some necessary files to the individual subject / individual run PPI directory in FSLoutput:
cp $REGDIR/highres.nii.gz $PPIdir/highres.nii.gz
cp $REGDIR/highres2standard.mat $PPIdir/highres2standard.mat
cp $REGDIR/example_func2highres.mat $PPIdir/example_func2highres.mat
cp $REGDIR/standard2example_func.mat $PPIdir/standard2example_func.mat
cp $SUBDATADIR/example_func.nii.gz $PPIdir/example_func.nii.gz

# OUTDIR=$DATADIR/PPITest
# mkdir -p $OUTDIR

# Look at data with thresholded fMRI data on top ---> get coordinates for ROI
fslview $DATADIR/cope1.feat/example_func.nii.gz $DATADIR/cope1.feat/thresh_zstat1.nii.gz -l Red-Yellow -b 2.3,6

# If your ROI is a single voxel (say, [59 35 22]), you don't need to create a mask, you can just get the timeseries for that coordinate as follows: 
fslmeants -i fslview $DATADIR/cope1.feat/example_func.nii.gz -o $PPIdir/group_vox_59_35_22.txt -c 59 35 22

# To see the values in the file:
# cat $PPIdir/test1.txt

# For a spherical ROI around a point, you need to create a mask over the previously identified single voxel of interest:
fslmaths $DATADIR/cope1.feat/example_func.nii.gz -mul 0 -add 1 -roi 59 1 35 1 22 1 0 1 $PPIdir/group_vox_59_35_22

# To create a larger spherical mask (here, 6mm) around the single voxel mask:
fslmaths $PPIdir/group_vox_59_35_22 -kernel sphere 6 -fmean $PPIdir/group_sphere_59_35_22
 
# Convert from Standard space to individual subject space:
flirt -applyxfm -init $PPIdir/standard2example_func.mat -in $PPIdir/group_sphere_59_35_22 -ref $SUBDATADIR/filtered_func_data.nii.gz -out $PPIdir/native_sphere_59_35_22

# Get timeseries, noting that fslmeants will extract the average timeseries from a fMRI file given any mask, be it a sphere, an anatomical region, etc: 
fslmeants -i $SUBDATADIR/filtered_func_data.nii.gz -o $PPIdir/native_sphere_59_35_22_ts.txt -m $PPIdir/native_sphere_59_35_22

# Take a look in individual subject space:
fslview /path/to/data/SD/FSLoutput/SD_001_20110701/Run1.feat/example_func.nii.gz $PPIdir/native_sphere_59_35_22 -l Red-Yellow -b 0,5

#
#
#
# Stuff for Grouped data in Standard space, given above parameters:
# --------------------------------------------------------------------------------------------------------------------
# To view results in standard space:
# fslview $DATADIR/cope1.feat/example_func.nii.gz $PPIdir/group_sphere_59_35_22
# 
# If desired, extract the average timeseries from the fMRI file (group data) for all voxels inside the sphere mask:
# fslmeants -i $DATADIR/cope1.feat/filtered_func_data.nii.gz -o $group_sphere_59_35_22_ts.txt -m $PPIdir/group_sphere_59_35_22
# --------------------------------------------------------------------------------------------------------------------
#
#
#


#
# Convert from standard brain space back to functional space to extract timeseries 

# First:

SubRegDir=/path/to/data/SD/FSLoutput/SD_001_20110701/Run1.feat/reg
PPIdir=/path/to/data/SD/FSLoutput/PPI/SD_001_20110701/Run1
mkdir -p $PPIdir
cp $SubRegDir/highres.nii.gz $PPIdir/highres.nii.gz
cp $SubRegDir/highres2standard.mat $PPIdir/highres2standard.mat
cp $SubRegDir/example_func2highres.mat $PPIdir/example_func2highres.mat
cp $SubRegDir/standard2example_func.mat $PPIdir/standard2example_func.mat
cp $SubRegDir/example_func $PPIdir/example_func

$FSLDIR/bin/fnirt --ref=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz --in=$PPIdir/highres.nii.gz --aff=$PPIdir/highres2standard.mat --cout=$PPIdir/highres2standard_warp --warpres=9,9,9

applywarp --ref=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz --in=/path/to/data/SD/FSLoutput/SD_001_20110701/Run1.feat/example_func.nii.gz --warp=$PPIdir/highres2standard_warp --premat=$PPIdir/example_func2highres.mat --out=$PPIdir/example_func_in_standard_space

convert_xfm -omat $PPIdir/highres2example_func.mat -inverse $PPIdir/example_func2highres.mat

invwarp --ref=$PPIdir/highres.nii.gz --warp=$PPIdir/highres2standard_warp --out=$PPIdir/highres2standard_warp_inv

applywarp --ref=/path/to/data/SD/FSLoutput/SD_001_20110701/Run1.feat/example_func.nii.gz --in=$OUTDIR/test1_sphere_mask  --warp=$PPIdir/highres2standard_warp_inv --postmat=$PPIdir/highres2example_func.mat --out=$PPIdir/mask_in_functional_space

fslmaths $PPIdir/mask_in_functional_space -thr 0.5 -bin $PPIdir/mask_in_functional_space

fslview $PPIdir/highres.nii.gz $PPIdir/native_space_ROI_mask -l Red-Yellow -b 0,5


flirt -applyxfm -init $PPIdir/standard2example_func.mat -in $OUTDIR/test2_sphere_mask -ref /path/to/data/SD/FSLoutput/SD_001_20110701/Run1.feat/example_func.nii.gz -out $PPIdir/native_space_ROI_mask

fslview /path/to/data/SD/FSLoutput/SD_001_20110701/Run1.feat/example_func.nii.gz $PPIdir/native_space_ROI_mask -l Red-Yellow -b 0,5
