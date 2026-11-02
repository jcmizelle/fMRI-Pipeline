#!/bin/bash

# JCM 3/20/2012
# Preliminary effort
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Begin File
# -----------------------------------------------------------------------------------------------------------------------------------
# export PATH=$PATH:/path/to/data/NEW_TOO
# chmod a+x /path/to/data/NEW_TOO/TOO_Tool_Subtraction
#
# This is the syntax to use at the command prompt to generate a list of all .FEAT directories to collapse into
# the "second" level analysis:
# cd /path/to/data/FSL-Test/FSLoutput
# ls -d1 `pwd`/*/*.feat
# -----------------------------------------------------------------------------------------------------------------------------------
# For each unique experiment, you will have to modify this script (and the template.fsf file) to match your parameters.
#
# The subjects are called in a primary loop, and are specified just below here. The naming convention does not matter, 
# so long as the names entered below match exactly to the name of the subject's folder in the FSLout directory.
#
# This conducts a Fixed Effects analysis to for each subject, averaging across the different runs. All of the specific experiment-related
# information is carried over from the initial proprocessing stages.
#
# Make sure to keep directories straight, as indicated in the code below.  This code works out of the "parent" directory of an experiment. 
# Other directories are created by this script, and files moved or created accordingly.
# Most of this is done automatically for you, but be careful - otherwise this will crash.
#
# There is very little file manipulation prior to executing the FSL statistical analysis.
#
# The critical part of batching runs/subjects is towards the bottom of the script, and is indicated as such.
# However, many of the directores needed are created and/or indexed in the early part of the script.
#
# There is a file check built in. If one of the necessary directories is missing, this will skip ahead to the 
# next subject (assuming multiple subjects) and will print an alert about the missing file.
# -----------------------------------------------------------------------------------------------------------------------------------

#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Set up subject loop here
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

for SUBJ in TOO_002_20100309 TOO_003_20100309 TOO_004_20100318 TOO_005_20100513 TOO_006_20100521 TOO_007_20101026 TOO_008_20101026 TOO_009_20110131 TOO_010_20110131 TOO_011_20110131 TOO_012_20110131 TOO_013_20110210 TOO_014_20110223; do

# Which subject is it?
SUBJ=$SUBJ

echo -e "\nWe are currently working on $SUBJ\n"

#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Take care of some early housekeeping: creating directories, moving files, creating handles, etc.
# -----------------------------------------------------------------------------------------------------------------------------------
#
#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Set some paths - change this by experiment, not by subject
# -----------------------------------------------------------------------------------------------------------------------------------
#

FSLDATADIR=/path/to/data/NEW_TOO/FSLoutput
SUBJDIR=${FSLDATADIR}/Level2/${SUBJ}.gfeat

cd ${SUBJDIR}
DIRLIST="`ls`"
echo -e "\nThe following files are in the subject's directory:\n"
echo -e "$DIRLIST\n"

#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Go back to study home directory
# -----------------------------------------------------------------------------------------------------------------------------------
#
#
 
cd ${FSLDATADIR}

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
export FSLDIR=/usr/local/fsl
.  ${FSLDIR}/etc/fslconf/fsl.sh

#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# This part is experiment-dependent -- change as needed
# -----------------------------------------------------------------------------------------------------------------------------------
#
#



#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Set some directories so that we can append subject(s) to it
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

#
# Reset home directory.  Chenge this to the specific study
#

FSLDATADIR=/path/to/data/NEW_TOO


#
# Give subject FSL output folder a handle for replacement in the *-template.fsf file
#

FSLSUBDATADIR=${FSLDATADIR}/FSLoutput/Level2/$SUBJ.gfeat

#
# Give a handle for FSL output to be replaced in the *-template.fsf file
#

FEATDIR=${FSLDATADIR}/FEATdir

#
# Now, create this output folder
#

mkdir -p ${FEATDIR}


#
# Now, give a handle for an output folder for all of the 2nd level analyses
#

SUBOUT=${FSLDATADIR}/FSLoutput/Level2/Tool-Subtraction/$SUBJ
#mkdir -p ${L2OUT}

#
# Make sure to go home, where the parent *-template.fsf file lives
#

cd $FSLDATADIR


#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Move through and change parameters in the design template (here, it is called TOO-Level2-template.fsf), which needs to be stored 
# in the "parent" directory.
# 
# This will move through each subject and create a specific FEAT.fsf file to execute the FSL analysis.
#
# It's not necessary to change all that many areas - make sure the changes are all IN CAPS:
# 
# 1) Output directory --> "OUTPUT" (with quotes)
# 2) 4D AVW data or FEAT directory (1) --> "FSLSUBDATADIR/Run1.feat" (with quotes)
# 3) 4D AVW data or FEAT directory (1) --> "FSLSUBDATADIR/Run2.feat" (with quotes)
# 4) 4D AVW data or FEAT directory (1) --> "FSLSUBDATADIR/Run3.feat" (with quotes)
# 5) 4D AVW data or FEAT directory (1) --> "FSLSUBDATADIR/Run4.feat" (with quotes)
# 6) 4D AVW data or FEAT directory (1) --> "FSLSUBDATADIR/Run5.feat" (with quotes)
# 7) 4D AVW data or FEAT directory (1) --> "FSLSUBDATADIR/Run6.feat" (with quotes)
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

#
# Set loops for runs on a (within) subject basis
#

	echo -e "We are working on $SUBJ\n"
	echo -e "Output of this analysis can be found in $SUBOUT.gfeat\n"

#
# Makes the NEW fsf files from the template (manually created) design.fsf file
#

	for i in 'Tool-Hand-Subtraction.fsf'; do

	sed -e 's@SUBOUT@'$SUBOUT'@g' \
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
