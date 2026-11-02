#!/bin/bash

# JCM 3/20/2012
# Preliminary effort
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Begin File
# -----------------------------------------------------------------------------------------------------------------------------------
# export PATH=$PATH:/path/to/data/TOP-5/
# chmod a+x /path/to/data/TOP-5/TOP-batch-Level2-Mask
# -----------------------------------------------------------------------------------------------------------------------------------
#

# Go ahead and give the overall data folder:
FSLDATADIR=/path/to/data/TOP-5


#for SUBJ in pilot_TOG_1_20100923 pilot_TOG_2_20100923 pilot_TOG_3_20100923 pilot_TOG_4_20100923 TOP_001_20110126 TOP_002_20110126 TOP_003_20110131 TOP_004_20110207 TOP_005_20110207 TOP_006_20110207 #TOP_007_20110214 TOP_008_20110210 TOP_009_20110223 TOP_010_20110422 TOP_011_20110422; do

for NUMSUBS in $*; do
# Assign handle to subject
SUBJ=$NUMSUBS
# Assign handle to subject
#SUBJ=$SUBJ

echo -e "\nThis script is currently working on......................$SUBJ\n"

FSLDATADIR=/path/to/data/TOP-5
cd ${FSLDATADIR}
SUBJDIR=${FSLDATADIR}/${SUBJ}

#
# Give subject FSL output folder a handle for replacement in the *-template.fsf file
#

FSLSUBDATADIR=${FSLDATADIR}/FSLoutput/$SUBJ

#
# Give a handle for FSL output to be replaced in the *-template.fsf file
#

FEATDIR=${FSLSUBDATADIR}/FEATdir

#
# Now, create this output folder
#

mkdir -p ${FEATDIR}


#
# Now, give a handle for an output folder for all of the 2nd level analyses
#

L2OUT=${FSLDATADIR}/FSLoutput/Level2-Mask/$SUBJ
#mkdir -p ${L2OUT}

#
# Generate a Binary Gray Matter Mask for every person
# 

# Set Data Directory
FSDATADIR=/path/to/data/TOP-3/FreeSurfer

# Create a directory for mask storage
mkdir -p $SUBJDIR/masks

# Selectively Binarize WM, CSF, Ventricles and Brainstem
echo -e "\nSelectively Binarizing WM, CSF, Ventricles and Brainstem......................$SUBJ\n"
mri_binarize --i $FSDATADIR/$SUBJ/mri/aparc+aseg.mgz --match 2 4 7 16 24 41 43 46 --o $SUBJDIR/masks/t1_wm.nii.gz

# Binarize Full Brain Mask, excluding "Unknown"
echo -e "\nBinarizing Full Brain Mask, excluding Unknown......................$SUBJ\n"
mri_binarize --i $FSDATADIR/$SUBJ/mri/aparc+aseg.mgz --match 0 --inv --o $SUBJDIR/masks/bin_full_mask.nii.gz

# Subtract WM/CSF/Ventricle/BS mask from Binarized Full Brain Mask
echo -e "\nSubtracting WM/CSF/Ventricle/BS mask from Binarized Full Brain Mask......................$SUBJ\n"
fsl5.0-fslmaths $SUBJDIR/masks/bin_full_mask.nii.gz -sub $SUBJDIR/masks/t1_wm.nii.gz $SUBJDIR/masks/GM_mask.nii.gz

# Give handle for later
GMMASK=$SUBJDIR/masks/GM_mask.nii.gz

# -----------------------------------------------------------------------------------------------------------------------------------
# This is the critical part of batching FSL analyses. 
# Directories are created and manipulated above, and are referenced below.
# Here is where we create the new design.fsf files, and execute FSL's FEAT.
# -----------------------------------------------------------------------------------------------------------------------------------
#
# 
# -----------------------------------------------------------------------------------------------------------------------------------
# Load the fsl program
# -----------------------------------------------------------------------------------------------------------------------------------

#
# Make sure to set the FSL directory according to your particular installation!
#
export FSLDIR=/usr/share/fsl/5.0/
.  ${FSLDIR}/etc/fslconf/fsl.sh



#
#

#
# Set loops for runs on a (within) subject basis
#

	echo -e "We are working on $SUBJ\n"
	echo -e "Output of this analysis can be found in $L2OUT.gfeat\n"

#
# Makes the NEW fsf files from the template (manually created) design.fsf file
#

	for i in 'L2-design-3.fsf'; do

	sed -e 's@L2OUT@'$L2OUT'@g' \
	    -e 's@SUBJ@'$SUBJ'@g' \
	    -e 's@GMMASK@'$GMMASK'@g' \
	    -e 's@FSLSUBDATADIR@'$FSLSUBDATADIR'@g' <$i> ${FEATDIR}/FEAT_${SUBJ}.fsf

#
# Close loop of FEAT*.fsf file creation
#
	done

#
# Execute the FSL analysis/es by calling the newly created FEAT*.fsf file
#

fsl5.0-feat ${FEATDIR}/FEAT_${SUBJ}.fsf


# End of subject loop
done
#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# End of file
# -----------------------------------------------------------------------------------------------------------------------------------
#
#
