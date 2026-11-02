#!/bin/bash

# JCM 3/20/2012
# Preliminary effort
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Begin File
# -----------------------------------------------------------------------------------------------------------------------------------
# export PATH=$PATH:/path/to/data/AU/
# chmod a+x /path/to/data/AU/AU-batch-2
# -----------------------------------------------------------------------------------------------------------------------------------
#

# Go ahead and give the overall data folder:
FSLDATADIR=/path/to/data/AU

# Make a folder to catch completion flags:
mkdir -p ${FSLDATADIR}/SubDone/
mkdir -p ${FSLDATADIR}/RunDone/


#SUBJ=pilot_1_AU_20120611

for NUMSUBS in $*; do
# Assign handle to subject
SUBJ=$NUMSUBS
# Report where we are
echo -e "\nThis script is currently working on......................$SUBJ\n"

#dcm2nii -d n -e n -m n -r y -x y /path/to/data/TOP-2/$SUBJ/fmri_1_6
#dcm2nii -d n -e n -m n -r y -x y /path/to/data/TOP-2/$SUBJ/t1_MPRAGE_2

export PATH=$PATH:/path/to/fMRI-Analysis-Tools/ScriptFiles
chmod a+x /path/to/fMRI-Analysis-Tools/ScriptFiles/Running_BXH-XCEDE
Running_BXH-XCEDE ${SUBJ}



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

# Give handles
FSLDATADIR=/path/to/data/AU
SUBJDIR=${FSLDATADIR}/${SUBJ}


if [ -f ${FSLDATADIR}/SubDone/${SUBJ}--DONE.txt ]; then
echo -e "Subject ${SUBJ} is complete ----------- moving on"
continue
fi

#elif [ ! -f $SUBJDIR/Complete.txt ]; then

# Get list of directories for evaluation
DIRLIST=`ls ${SUBJDIR}`

# Report what was found
echo -e "The following subdirectories are in the subject's home directory:\n"
echo -e "$DIRLIST\n"

#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# File check - jump to next subject if not here (or maybe crash the program...we'll see).
# At each stage, report if the specific directories were found, or if moving on because they were not.
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

# Are there anatomicals?
## 	T1?
	if [[ "$DIRLIST" =~ "MPRAGE" ]]; then
	    echo -e "Found the T1......................"
	else
	    echo -e "I could not find a T1 for ${SUBJ}......................Jumping to next subject"
            continue
            #break
	fi

## 	T2?
	if [[ "$DIRLIST" =~ "space" ]]; then
	    echo -e "Found the T2......................"
	else
    	    echo -e "I could not find a T2 for ${SUBJ}, but will continue to process......................"
	    #continue
    	    #break
	fi

# Are there functionals?
	if [[ "$DIRLIST" =~ "fmri" ]]; then
	    echo -e "Found the functionals......................"
	else
	    echo -e "I could not find functional images for ${SUBJ}......................Jumping to next subject"
	    continue
	    #break
	fi

# Are there B0 images?
## 	Short-TR phase image?
	if [[ "$DIRLIST" =~ "mapping_3" ]]; then
	    echo -e "Found the phase magnitude image......................"
	else
	    echo -e "I could not find the gre_3 phase magnitude image for ${SUBJ}......................Jumping to next subject"
	    continue
	    #break
	fi

## 	Modulus image (checking for both of the directory name conventions)?
	if [[ "$DIRLIST" =~ "mapping_4" ]]; then
	    echo -e "Found the phasemap image......................"
	elif [[ "$DIRLIST" =~ "mapping_b_4" ]]; then
	    echo -e "Found the phasemap image......................"
	else
	    echo -e "I could not find the gre_4 phasemap image for ${SUBJ}......................Jumping to next subject"
	    continue
	    #break
	fi

# Are there event onset files?
	ONSET_CHECK=`ls -d1 $FSLDATADIR/Onset-Files | grep Ons`
	if [ ! -z "$ONSET_CHECK" ]; then
	    echo -e "Found the event onset files......................"
	else
	    echo -e "I could not find onset files\nThese need to be added to a folder called ""Onset-Files"" in the parent directory "
	    continue
	    #break
	fi

# If we made it this far, we should be OK...
echo -e "Looks like everything is here. Will begin processing................\n"


#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Go to study home directory, where we'll be working
# -----------------------------------------------------------------------------------------------------------------------------------
#
#
 
cd ${FSLDATADIR}


# Get original functional folders and set handle for runs
RUNS=`ls $SUBJDIR | grep fmri`

if [ -d ${SUBJDIR}/Functional/ ]; then 

echo -e "Functional directories already exist ----------- moving on"

elif [ ! -d ${SUBJDIR}/Functional/ ]; then

# Set counter
counter=1

##	Loop it over runs
	for i in ${RUNS}; do
	    
	    if [ ! -d ${SUBJDIR}/Functional/Run${counter}/ ]; then

	    echo -e "Moving functional data for......................Run ${counter}"

##	    Make the new folders
	    mkdir -p ${SUBJDIR}/Functional/Run${counter}/

##	    Convert the files from DICOM
	    #dcm2nii -d n -e n -m n -r y -x y ${SUBJDIR}/${i}

##	    Move the files
	    cp ${SUBJDIR}/${i}/fmri*.nii.gz ${SUBJDIR}/Functional/Run${counter}/fmri.nii.gz
	    echo -e "Copying ${SUBJDIR}/${i}/fmri*.nii.gz to ${SUBJDIR}/Functional/Run${counter}/fmri.nii.gz..........................."

##	    Iterate counter
	    counter=$((counter+1))
	   
	    fi

##	End loop with last run
	done

fi

##      Subtract Intact from the other conditions
#	fslmaths ${SUBJDIR}/Functional/Run2/fmri2.nii -sub ${SUBJDIR}/Functional/Run1/fmri1.nii ${SUBJDIR}/Functional/Run2/fmri2SUBTRACT.nii 
#	fslmaths ${SUBJDIR}/Functional/Run3/fmri3.nii -sub ${SUBJDIR}/Functional/Run1/fmri1.nii ${SUBJDIR}/Functional/Run3/fmri2SUBTRACT.nii 
#	fslmaths ${SUBJDIR}/Functional/Run4/fmri4.nii -sub ${SUBJDIR}/Functional/Run1/fmri1.nii ${SUBJDIR}/Functional/Run4/fmri2SUBTRACT.nii 

##      Merge conditions
#	fslmerge -t ${SUBJDIR}/Functional/Run2/fmri2b.nii ${SUBJDIR}/Functional/Baseline/fmri1.nii ${SUBJDIR}/Functional/Run2/fmri2.nii
#	fslmerge -t ${SUBJDIR}/Functional/Run3/fmri3b.nii ${SUBJDIR}/Functional/Baseline/fmri1.nii ${SUBJDIR}/Functional/Run3/fmri3.nii	
#	fslmerge -t ${SUBJDIR}/Functional/Run4/fmri4b.nii ${SUBJDIR}/Functional/Baseline/fmri1.nii ${SUBJDIR}/Functional/Run4/fmri4.nii

#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Get directory for the T1 and give it a handle
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

if [[ `ls $SUBJDIR` =~ .*t1.* ]]; then 
T1DIR=`ls $SUBJDIR | grep ^t1`
elif [[ `ls $SUBJDIR` =~ .*T1.* ]]; then 
T1DIR=`ls $SUBJDIR | grep ^T1`
fi


#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Get directory for the T2 and give it a handle
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

if [[ `ls $SUBJDIR` =~ .*t2.* ]]; then 
T2DIR=`ls $SUBJDIR | grep ^t2`
elif [[ `ls $SUBJDIR` =~ .*T2.* ]]; then 
T2DIR=`ls $SUBJDIR | grep ^T2`
fi


#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Create a STANDARDIZED directory for pending anatomical scans, and give it a handle
# Move DICOM converted (*.nii) T1 and T2 (if it exists) images to the Anatomical directory, if they have not been moved
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

# Give the anatomical directory a handle
ANATDIR=${FSLDATADIR}/${SUBJ}/Anatomical

if [ -d ${ANATDIR}/T1 ]; then
echo -e "Anatomical directories already exist ----------- moving on"
fi

if [ ! -d ${ANATDIR}/T1 ]; then

echo -e "Creating the anatomical directories as needed................"

# Make Anatomical directory
#mkdir -p ${ANATDIR}

# Report
echo -e "Making a T1 folder................"
echo -e "Converting the T1 from DICOM to NiFTI................"
#dcm2nii -d n -e n -m n -r y -x y ${FSLDATADIR}/${SUBJ}/${T1DIR}

# Move the T1(s)
T1ANATDIR=${ANATDIR}/T1
mkdir -p ${T1ANATDIR}

# Report
echo -e "And now moving the T1 structural data................"
cp ${FSLDATADIR}/${SUBJ}/${T1DIR}/*.nii.gz ${T1ANATDIR}

# Move the T2(s), if they exist
    if [ ! -z  "${T2DIR}" ]; then
    T2ANATDIR=${ANATDIR}/T2
    #dcm2nii -d n -e n -m n -r y -x y ${FSLDATADIR}/${SUBJ}/${T2ANATDIR}
    mkdir -p ${T2ANATDIR}
    echo -e "And now moving the T2 structural data................"
    cp ${FSLDATADIR}/${SUBJ}/${T2DIR}/*.nii.gz ${T2ANATDIR}
    else echo -e "There will be no T2 directory................"    
    fi

fi


#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Give handles to T1 and T2 images for use below
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

# Get full file names:
#if [ -d ${T1ANATDIR} ]; then
#my_T1=`ls ${T1ANATDIR}/t1*`
#elif [ ! -z ${my_T1} ]; then
#my_T1=`ls ${T1ANATDIR}/T1*`
#fi
#
#if [ ! -d ${T2ANATDIR} ]; then
#my_T2=`ls {T2ANATDIR}/T2*`
#elif [ ! -z ${my_T1} ]; then
#fi

if [[ `ls $T1ANATDIR` =~ .*t1.* ]]; then 
my_T1=`ls $T1ANATDIR | grep ^t1`
elif [[ `ls $T1ANATDIR` =~ .*T1.* ]]; then 
my_T1=`ls $T1ANATDIR | grep ^T1`
fi

if [[ `ls $T2ANATDIR` =~ .*T2.* ]]; then 
my_T2=`ls $T2ANATDIR | grep ^T2`
elif [[ `ls $T2ANATDIR` =~ .*t2.* ]]; then 
my_T2=`ls $T2ANATDIR | grep ^t2`
fi

# To return the full path, but with no extension:
# my_T1=`remove_ext $my_T1`
# my_T2=`remove_ext $my_T2`

# To return only the file name (no path or extension):
my_T1=`basename ${my_T1} .nii.gz`

if [ ! -z  "${my_T2}" ]; then
my_T2=`basename ${my_T2} .nii.gz`
fi

# For adding text to the end of the filename, while removing white space:
# my_T1out="$my_T1 _brain"
# my_T1out=${my_T1out/ /}


#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# There is apparently an orientation discrepancy between what FSL wants and what our anatomical scans are.  
# We'll fix this below for the T1 and T2.
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

#
# Set output names
#
my_T1R="${my_T1}Reoriented"

if [ ! -z "${my_T2}" ]; then
my_T2R="${my_T2}Reoriented"
fi

#
# Do the reorientation, if is hasn't been done already
#
if [ -e ${T1ANATDIR}/${my_T1R}.* ]; then
echo -e "Anatomical T1 has already been reoriented ----------- moving on"
fi

# Reorient the T1
if [ ! -e ${T1ANATDIR}/${my_T1R}.* ]; then
# Report
echo -e "Performing reorientation of the anatomical T1 images................"
fsl5.0-fslreorient2std ${T1ANATDIR}/${my_T1}.nii.gz ${T1ANATDIR}/${my_T1R}.nii.gz 
fi

if [ -e ${T2ANATDIR}/${my_T2R}.* ]; then
echo -e "Anatomical T2 has already been reoriented ----------- moving on"
fi

# Reorient the T2, if it exists
if [ -e ${T2ANATDIR}/${my_T2}.nii.gz ]; then
# Report
echo -e "Performing reorientation of the anatomical T2 images................"
fsl5.0-fslreorient2std ${T2ANATDIR}/${my_T2}.nii.gz ${T2ANATDIR}/${my_T2R}.nii.gz 
fi


#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Do the T1-T2 coregistration if there is a T2, and locate the image in the anatomical directory.
# Not needed for basic fmri analysis, so commented out
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

#if [[  $T1DIR && ${T2DIR-x} ]] && echo "Found a T2 and starting T2-T1 coregistration" 
#then

#/usr/local/fsl/bin/flirt -in ${ANATDIR}/${my_T2R}.nii -ref ${ANATDIR}/${my_T1R}.nii -out ${ANATDIR}/T2-T1coreg.nii -omat ${ANATDIR}/T2-T1coreg.mat -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6  -interp trilinear

#else echo "There was no T2 for this subject"
#fi


#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Go ahead and run brain extraction for later use in registration - stick it in the anatomical directory
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

#
# Set the output
#
my_T1RB="${my_T1R}_brain"

if [ ! -z "${my_T2R}" ]; then
my_T2RB="${my_T2R}_brain"
fi

#
# Do the extraction, with the -R for multiple iterations of bet2, and -B to reduce image bias
#
if [ -e ${T1ANATDIR}/${my_T1RB}.* ]; then
echo -e "T1 brain extraction has already been performed ----------- moving on"
fi

if [ ! -e ${T1ANATDIR}/${my_T1RB}.* ]; then
# Report
echo -e "Performing brain extraction on the T1................"
# Extract T1 brain
fsl5.0-bet ${T1ANATDIR}/${my_T1R}.nii.gz ${T1ANATDIR}/${my_T1RB}.nii.gz -B -f 0.5 -g 0 -R
fi

# If there is a T2, go ahead and do that here too
if [ -e ${T2ANATDIR}/${my_T2}.nii.gz ]; then
# Report
echo -e "Performing brain extraction on the T2................"
# Extract T2 brain
fsl5.0-bet ${T2ANATDIR}/${my_T2R}.nii.gz ${T2ANATDIR}/${my_T2RB}.nii.gz -B -f 0.5 -g 0 -R
fi

# If you wanted to get surfaces (scalp, scull) for later use, you could uncomment the following command
# using -B to reduce image bias and -A2 to improve skull/scalp surfaces and register T1 and T2 images
# /usr/local/fsl/bin/bet ${ANATDIR}/${my_T1R}.nii ${ANATDIR}/${my_T1RB}.nii -B -f 0.5 -g 0 -A2 ${ANATDIR}/${my_T2R}.nii

#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# The stuff commented below is just some registration stuff I've been playing with. 
# Not needed for standard fMRI analysis.
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

# Set the output

# my_T1RBW="$my_T1RB _warped"
# my_T1RBW=${my_T1RBW/ /}

# Registering T1-structural to MNI152

# flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in ${ANATDIR}/${my_T1RB}.nii -omat my_affine_transf.mat
# fnirt --in=${ANATDIR}/${my_T1R}.nii --aff=my_affine_transf.mat --cout=my_nonlinear_transf --config=T1_2_MNI152_2mm 
# applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=${ANATDIR}/${my_T1R}.nii --warp=my_nonlinear_transf --out=${ANATDIR}/${my_T1RBW}.nii

# Registering functional data to MNI152 (via structural scan) 

# bet ${Anatomical}/${my_T1R} ${Anatomical}/${my_T1RB} is a prerequisite for this

# flirt -ref ${ANATDIR}/${my_T1RB}.nii -in my_functional -dof 7 -omat func2struct.mat
# flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in ${ANATDIR}/${my_T1RB}.nii -omat my_affine_transf.mat
# fnirt --in=my_structural --aff=my_affine_transf.mat --cout=my_nonlinear_transf --config=T1_2_MNI152_2mm
# applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=my_functional --warp=my_nonlinear_transf --premat=func2struct.mat --out=my_warped_functional


#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Fieldmap correction is implemented with details below.
# TURN THIS OFF IN FEAT .fsf SETUP IF YOU DO NOT WANT TO DO THIS!
# If proceeding, the required output files to be used with FUGUE are:
# 1) Brain extracted modulus image (created as MODbrain.nii)
# 2) Field map in rad/s (created as FIELDmap_rads.nii)
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

# Report
echo -e "Performing fieldmap computations................"

#
# Get necessary directories
# 

# Modulus image
temp=`ls $SUBJDIR | grep mapping_3`
MODDIR=($temp)
MODDIR=$SUBJDIR/$MODDIR
if [ "$MODDIR" ]; then
dcm2nii -d n -e n -m n -r y -x y ${MODDIR}
fi

# Phase image
#
# Check to make sure that mapping_4 is the correct directory name - sometimes this will come out of the scanner as mapping_b_4.
# The filecheck evaluated both, determine which is correct here, and give it a handle.
#

PHASEDIR=`ls $SUBJDIR | grep mapping_4`
if [ "$PHASEDIR" ]; then
PHASEDIR=$SUBJDIR/$PHASEDIR
dcm2nii -d n -e n -m n -r y -x y ${PHASEDIR}
elif [ "$PHASEDIR" = "" ]; then
PHASEDIR=`ls $SUBJDIR | grep mapping_b_4`
PHASEDIR=$SUBJDIR/$PHASEDIR
dcm2nii -d n -e n -m n -r y -x y ${PHASEDIR}
fi


#
# Create and set a new Fmaps directory for the fieldmap manipulations
#

mkdir -p ${SUBJDIR}/Fmaps
FIELDDIR=${SUBJDIR}/Fmaps

#
# Create a skull-stripped brain mask using the modulus of the field map
# MODbrain.nii is the output and is used in FUGUE.
#

# Report
if [ -e ${FIELDDIR}/MODbrain.nii.gz ]; then
echo -e "Modulus image has already been skull stripped -- moving on ----------- moving on"

elif [ ! -e ${FIELDDIR}/MODbrain.nii.gz ]; then

echo -e "Skull stripping modulus image................"
# Do it
fsl5.0-bet ${MODDIR}/*.nii.gz ${FIELDDIR}/MODbrain.nii.gz -f 0.5 -m -R

fi

#
# Use the command line fslmaths utility to convert the data from the 12-bit integer format (scaled from 0 to 4095) 
# to radians (measure of phase evolution between 2 echo times in fieldmap acquisition). Input file is the phase part 
# of the fieldmap, output is a file named PHASE_rad.nii 
#

if [ -e ${FIELDDIR}/FIELDmap_rads.nii.gz ]; then
echo -e "Fieldmap has already been generated ----------- moving on"

elif [ ! -e ${FIELDDIR}/FIELDmap_rads.nii.gz ]; then
# Report
echo -e "Converting the phasemap from integer to radians................"
# Do it
fsl5.0-fslmaths ${PHASEDIR}/*.nii.gz -div 4096 -mul 3.14159 ${FIELDDIR}/PHASE_rad.nii.gz -odt float

#
# Use PRELUDE to unwrap the phase map (spins that evolve more than pi during the delta echo time cause discontinuities in the
# fieldmap). We are using MODbrain_mask as a mask. Output is written to PHASE_rad_unwrapped.nii
#

# Report
echo -e "Unwrapping the phasemap................"
# Do it
fsl5.0-prelude -p ${FIELDDIR}/PHASE_rad.nii.gz -a ${FIELDDIR}/MODbrain.nii.gz -m ${FIELDDIR}/MODbrain_mask.nii.gz -o ${FIELDDIR}/PHASE_rad_unwrapped.nii.gz 

#
# Now convert the unwrapped phase map into a fieldmap (in rad/s), by dividing by the delta echo-time from the fieldmap sequence. 
# The delta TE in our sequence is 2.46ms. Output is written to FIELDmap_rads.nii, which is used in FUGUE.
#

# Report
echo -e "Converting the unwrapped phase map into a fieldmap (rad/s)................"
# Do it
fsl5.0-fslmaths ${FIELDDIR}/PHASE_rad_unwrapped.nii.gz -div 0.00246 ${FIELDDIR}/FIELDmap_rads.nii.gz

fi

#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# You can manually check the outcome of the B0 correction by uncommenting and following the steps below:
# -----------------------------------------------------------------------------------------------------------------------------------
#
#

#
# Compute mean functional EPI
#

#FUNDIR=${SUBJDIR}/Run1

#/usr/local/fsl/bin/fslmaths ${FUNDIR}/*.nii -Tmean ${FUNDIR}/mean.nii

#
# Apply field map to EPI mean image, with a dewll time of .49ms
#

#/usr/local/fsl/bin/fugue -i ${FUNDIR}/mean.nii --loadfmap=${FIELDDIR}/PHASEmask_inRAD.nii --dwell=.00049 -u ${FIELDDIR}/testfield.nii --unwarpdir=y-


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

FSLDATADIR=/path/to/data/AU

#
# Identify subject number for replacement in the *-template.fsf file
#

SUBNUM=$SUBJ

#
# Give subject folder a handle for replacement in the *-template.fsf file
#

FSLSUBDATADIR=${FSLDATADIR}/$SUBJ

#
# Give a handle for FSL output to be replacemed in the *-template.fsf file
#

FEATDIR=${FSLSUBDATADIR}/FEATdir

#
# Now, create this output folder
#

mkdir -p ${FEATDIR}


#
# Make sure to go home, where the parent *-template.fsf file lives
#

cd $FSLDATADIR


#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Move through and change parameters in the design template (here, it is called TOO-template.fsf), which needs to be stored in the "parent" directory.
# This will move through each subject/run and create a specific FEAT.fsf file to execute the FSL analysis.
#
# It's not necessary to change all that many areas - make sure the changes are all IN CAPS:
# 
# 1) Output directory --> "OUTDATA" (with quotes)
# 2) 4D AVW data or FEAT directory (1) --> "FUNDATA" (with quotes)
# 3) B0 unwarp input image for analysis 1 --> "B0FIELD" (with quotes)
# 4) B0 unwarp mag input image for analysis 1 --> "B0MOD" (with quotes)
# 5) Subject's structural image for analysis 1 --> "ANATFILE" (with quotes)
# 6) Custom EV file (EV 1) --> "ONS1" (with quotes)
# 7) Custom EV file (EV 2) --> "ONS2" (with quotes)
# 8) Custom EV file (EV 3) --> "ONS3" (with quotes)
# 9) Custom EV file (EV 4) --> "ONS4" (with quotes)

# MAYBE change the TRS

# -----------------------------------------------------------------------------------------------------------------------------------
#
#

#
# Specify an anatomical image handle (betted image as created above) to be replaced in the *-template.fsf file
# This will be used in FNIRT - nonlinear registration following FLIRT
#

ANATFILE=${T1ANATDIR}/$my_T1RB.nii.gz

FUNDATADIR=${FSLSUBDATADIR}/Functional
DORUNS=`ls $FUNDATADIR | grep Run`
#
# Set loops for runs on a (within) subject basis
#

	for RUN in $DORUNS; do # I may think of automating this run counter...
		if [ -f ${FSLDATADIR}/RunDone/${SUBJ}-${RUN}--DONE.txt ]; then
		echo -e "Run $RUN of $SUBNUM done -- moving on\n"

		elif [ ! -d ${OUTDATA}/${RUN}.feat ] && [ ! -f ${OUTDATA}/${RUN}.feat/Complete.txt ]; then


		ANATFILE=${T1ANATDIR}/$my_T1RB.nii.gz
		OUTDATA=${FSLDATADIR}/FSLoutput/${SUBNUM}/${RUN}
		B0FIELD=${FSLSUBDATADIR}/Fmaps/FIELDmap_rads.nii.gz
		B0MOD=${FSLSUBDATADIR}/Fmaps/MODbrain.nii.gz
		
		RUNNUM=${RUN}


# Report
		echo -e "\nWe are working on $RUN of $SUBNUM\n"
		echo -e "Output of this analysis can be found in $OUTDATA.feat\n"
#
# Makes the NEW fsf files from the template (manually created) design.fsf file
#

		    if [[ "$SUBJ" == "pilot_1"* ]]; then 
			TRS=153
			if [ \(    "$RUNNUM" = "Run1"          	\
			        -o "$RUNNUM" = "Run2"       	\
			        -o "$RUNNUM" = "Run3"    	\
							    \)  ] 
				then
				ONS1=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons1
				ONS2=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons2
				ONS3=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons3
				ONS4=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons4

			elif [ \(  "$RUNNUM" = "Run4"          	\
			       	-o "$RUNNUM" = "Run5"       	\
			        -o "$RUNNUM" = "Run6"    	\
							    \)  ] 
				then
				ONS1=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons5
				ONS2=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons6
				ONS3=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons7
				ONS4=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons8
			fi
				FUNDATA=${FSLSUBDATADIR}/Functional/${RUN}/fmri.nii.gz
				for i in 'pilot_batch.fsf'; do
	
				sed -e 's@ANATFILE@'$ANATFILE'@g' \
	    	    		    -e 's@SUBNUM@'$SUBNUM'@g' \
		    	    	    -e 's@OUTDATA@'$OUTDATA'@g' \
			    	    -e 's@RUNNUM@'$RUNNUM'@g' \
			    	    -e 's@FSLDATADIR@'$FSLDATADIR'@g' \
				    -e 's@B0FIELD@'$B0FIELD'@g' \
				    -e 's@B0MOD@'$B0MOD'@g' \
				    -e 's@ONS1@'$ONS1'@g' \
				    -e 's@ONS2@'$ONS2'@g' \
				    -e 's@ONS3@'$ONS3'@g' \
				    -e 's@ONS4@'$ONS4'@g' \
				    -e 's@TRS@'$TRS'@g' \
			    	    -e 's@FUNDATA@'$FUNDATA'@g' <$i> ${FEATDIR}/FEAT_${RUN}.fsf
		
				done


		    elif [[ "$SUBJ" == "pilot_2"* ]]; then 
			TRS=149
			if [ \(    "$RUNNUM" = "Run1"          	\
			        -o "$RUNNUM" = "Run2"       	\
			        -o "$RUNNUM" = "Run3"    	\
							    \)  ] 
				then
				ONS1=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons1
				ONS2=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons2
				ONS3=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons3
				ONS4=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons4

			elif [ \(  "$RUNNUM" = "Run4"          	\
			       	-o "$RUNNUM" = "Run5"       	\
			        -o "$RUNNUM" = "Run6"    	\
							    \)  ] 
				then
				ONS1=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons5
				ONS2=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons6
				ONS3=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons7
				ONS4=${FSLDATADIR}/Pilot-Onset-Files/${RUN}/Ons8
			fi			
			FUNDATA=${FSLSUBDATADIR}/Functional/${RUN}/fmri.nii.gz
				for i in 'pilot_batch.fsf'; do
	
				sed -e 's@ANATFILE@'$ANATFILE'@g' \
	    	    		    -e 's@SUBNUM@'$SUBNUM'@g' \
		    	    	    -e 's@OUTDATA@'$OUTDATA'@g' \
			    	    -e 's@RUNNUM@'$RUNNUM'@g' \
			    	    -e 's@FSLDATADIR@'$FSLDATADIR'@g' \
				    -e 's@B0FIELD@'$B0FIELD'@g' \
				    -e 's@B0MOD@'$B0MOD'@g' \
				    -e 's@ONS1@'$ONS1'@g' \
				    -e 's@ONS2@'$ONS2'@g' \
				    -e 's@ONS3@'$ONS3'@g' \
				    -e 's@ONS4@'$ONS4'@g' \
				    -e 's@TRS@'$TRS'@g' \
			    	    -e 's@FUNDATA@'$FUNDATA'@g' <$i> ${FEATDIR}/FEAT_${RUN}.fsf
		
				done

		    elif [[ ! "$SUBJ" == "pilot"* ]]; then
			ONS1=${FSLDATADIR}/Onset-Files/${RUN}/Ons1
			ONS2=${FSLDATADIR}/Onset-Files/${RUN}/Ons2
			ONS3=${FSLDATADIR}/Onset-Files/${RUN}/Ons3
			ONS4=${FSLDATADIR}/Onset-Files/${RUN}/Ons4
			TRS=222
			FUNDATA=${FSLSUBDATADIR}/Functional/${RUN}/fmri.nii.gz
				for i in 'AU_batch.fsf'; do
	
				sed -e 's@ANATFILE@'$ANATFILE'@g' \
    	    			    -e 's@SUBNUM@'$SUBNUM'@g' \
	    		    	    -e 's@OUTDATA@'$OUTDATA'@g' \
			    	    -e 's@RUNNUM@'$RUNNUM'@g' \
			    	    -e 's@FSLDATADIR@'$FSLDATADIR'@g' \
				    -e 's@B0FIELD@'$B0FIELD'@g' \
				    -e 's@B0MOD@'$B0MOD'@g' \
				    -e 's@ONS1@'$ONS1'@g' \
				    -e 's@ONS2@'$ONS2'@g' \
				    -e 's@ONS3@'$ONS3'@g' \
				    -e 's@ONS4@'$ONS4'@g' \
				    -e 's@TRS@'$TRS'@g' \
			    	    -e 's@FUNDATA@'$FUNDATA'@g' <$i> ${FEATDIR}/FEAT_${RUN}.fsf

				done

#xterm -e "fsl5.0-feat ${FEATDIR}/FEAT_${RUN}.fsf" &

		    fi

#
# Execute the FSL analysis/es by calling the newly created FEAT*.fsf file
#


## run the job
fsl5.0-feat ${FEATDIR}/FEAT_${RUN}.fsf

# Create "run done" flag
		echo `date +%F_%T` > ${FSLDATADIR}/RunDone/${SUBJ}-${RUN}--DONE.txt

		fi


#
# End loop through runs
#
	done

# Create "subject done" flag
echo `date +%F_%T` > ${FSLDATADIR}/SubDone/${SUBJ}--DONE.txt


# End across-subject loop
done

#
#
# -----------------------------------------------------------------------------------------------------------------------------------
# End of file
# -----------------------------------------------------------------------------------------------------------------------------------
#
#
