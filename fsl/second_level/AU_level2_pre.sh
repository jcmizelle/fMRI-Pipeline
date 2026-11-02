#!/bin/bash

# JCM 3/20/2012
# Preliminary effort
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Begin File
# -----------------------------------------------------------------------------------------------------------------------------------
# export PATH=$PATH:/path/to/data/AU/
# chmod a+x /path/to/data/AU/AU-batch-Level2-PRE
# -----------------------------------------------------------------------------------------------------------------------------------
#

# Go ahead and give the overall data folder:
FSLDATADIR=/path/to/data/AU


for SUBJ in AU__001_20120619 AU__002_20120619 AU_003_20120621 AU_004_20120628 AU_005_20120628 AU_006_20120703 AU_007_20120706 AU_008_20120713 AU_009_20120717 AU_010_20120719 AU_011_20120719; do

# Assign handle to subject
SUBJ=$SUBJ
#for NUMSUBS in $*; do
# Assign handle to subject
#SUBJ=$NUMSUBS
echo -e "\nThis script is currently working on......................$SUBJ\n"

FSLDATADIR=/path/to/data/AU
cd ${FSLDATADIR}
SUBJDIR=${FSLDATADIR}/${SUBJ}

#
# Give subject FSL output folder a handle for replacement in the *-template.fsf file
#

FSLSUBDATADIR=${FSLDATADIR}/FSLoutput/level2/PreCuff/$SUBJ/

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

L2OUT=${FSLDATADIR}/FSLoutput/Level2/PreCuff/$SUBJ
#mkdir -p ${L2OUT}
#
#
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

	for i in 'L2_batch-PRE.fsf'; do

	sed -e 's@L2OUT@'$L2OUT'@g' \
	    -e 's@SUBJ@'$SUBJ'@g' \
	    -e 's@FSLSUBDATADIR@'$FSLSUBDATADIR'@g' <$i> ${FEATDIR}/FEAT_${SUBJ}.fsf

#
# Close loop of FEAT*.fsf file creation
#
	done

#
# Execute the FSL analysis/es by calling the newly created FEAT*.fsf file
#

feat ${FEATDIR}/FEAT_${SUBJ}.fsf


# End of subject loop
done
#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# End of file
# -----------------------------------------------------------------------------------------------------------------------------------
#
#
