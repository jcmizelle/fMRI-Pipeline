#!/bin/bash

# JCM 3/12/2014
#
# -----------------------------------------------------------------------------------------------------------------------------------
# Begin File
# -----------------------------------------------------------------------------------------------------------------------------------
# export PATH=$PATH:/path/to/data/AandA/
# chmod a+x /path/to/data/AandA/AandA-batch
# AA_001_20140303 AA_002_20140303 AA_003_20140305 AA_004_20140305 AA_005_20140305 AA_006_20140305 AA_007_20140306 AA_008_20140306 AA_009_20140306 AA_010_20140311 AA_011_20140311 AA_012_20140313 AA_013_20140313

# -----------------------------------------------------------------------------------------------------------------------------------
#

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Specify the parent folder for this study, and make that the working directory:
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
FSLDATADIR=/path/to/data/AandA
cd ${FSLDATADIR}

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Make folders to catch completion flags:
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
mkdir -p ${FSLDATADIR}/SubDone/
mkdir -p ${FSLDATADIR}/RunDone/

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Initialise outer loop for subjects with the handle SUBJ:
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
for SUBJ in $*; do

# -----------------------------------------------------------------------------------------------------------------------------------
# Report where we are
# -----------------------------------------------------------------------------------------------------------------------------------
echo -e "\nThis script is currently working on......................${FSLDATADIR}/$SUBJ\n"


# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Identify the location of the DICOM data:
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
RAWDATA=${FSLDATADIR}/DICOM/${SUBJ}

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Set and create a place for converted data to go:
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
SUBJDIR=${FSLDATADIR}/SubjectData/${SUBJ}
mkdir -p ${SUBJDIR}

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Check for interfering folder names (esp. fMRI_Loc*).  If identified, move them to a new folder "Unused":
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
tmpVar=`ls ${RAWDATA} | grep fMRI_Loc`
if [ -n "${tmpVar}" ]; then 
mkdir -p ${RAWDATA}/Unused
mv ${RAWDATA}/${tmpVar} ${RAWDATA}/Unused/
fi

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Check to see if BXH-CEDE has run before, creating an output if not and starting the process:
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
QADIR=${SUBJDIR}/QA
if [ ! -d ${QADIR} ]; then
mkdir ${QADIR}


# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Get things set up for BXH-CEDE:
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
#progDir='/path/to/data-Analysis-Tools/BXH-XCEDE/bxh_xcede_tools-1.10.7-lsb30.x86_64/bin'
progDir='/path/to/fMRI-Analysis-Tools/BXH-XCEDE/bxh_xcede_tools-1.10.7-lsb30.x86_64/bin'

# -----------------------------------------------------------------------------------------------------------------------------------
# Identify files and begin conversion to BXH, starting with functional
# -----------------------------------------------------------------------------------------------------------------------------------
RUNS=`ls ${RAWDATA} | grep fMRI`
for i in ${RUNS}; do
    ${progDir}/bxhabsorb ${RAWDATA}/${i}/*.dcm ${QADIR}/BXHout_${i}.bxh


# -----------------------------------------------------------------------------------------------------------------------------------
# Evaluate the functional data with BXH-CEDE, sending findings to a single text file for evaluation (BXH-XCEDE_EVAL.txt).  Start
# with creating a place for the QA data to go.
# -----------------------------------------------------------------------------------------------------------------------------------


## Get BXH-XCEDE results for the important things, 
    echo ${SUBJDIR} >> ${QADIR}/BXH-XCEDE_EVAL.txt
    echo `date +%F_%T` >> ${QADIR}/BXH-XCEDE_EVAL.txt
    echo "" >> ${QADIR}/BXH-XCEDE_EVAL.txt

    echo -e "Run ${i}" >> ${QADIR}/BXH-XCEDE_EVAL.txt
    ${progDir}/dumpheader ${QADIR}/BXHout_${i}.bxh | grep Byte >> ${QADIR}/BXH-XCEDE_EVAL.txt
    ${progDir}/dumpheader ${QADIR}/BXHout_${i}.bxh | grep RASflag >> ${QADIR}/BXH-XCEDE_EVAL.txt
    ${progDir}/dumpheader ${QADIR}/BXHout_${i}.bxh | grep 'acqdata: fieldofview =' >> ${QADIR}/BXH-XCEDE_EVAL.txt
    ${progDir}/dumpheader ${QADIR}/BXHout_${i}.bxh | grep 'acqdata: tr =' >> ${QADIR}/BXH-XCEDE_EVAL.txt
    ${progDir}/dumpheader ${QADIR}/BXHout_${i}.bxh | grep 'acqdata: te =' >> ${QADIR}/BXH-XCEDE_EVAL.txt
    ${progDir}/dumpheader ${QADIR}/BXHout_${i}.bxh | grep sliceorder >> ${QADIR}/BXH-XCEDE_EVAL.txt
    ${progDir}/dumpheader ${QADIR}/BXHout_${i}.bxh | grep Dimension >> ${QADIR}/BXH-XCEDE_EVAL.txt
    ${progDir}/dumpheader ${QADIR}/BXHout_${i}.bxh >> ${QADIR}/DICOM-Header.txt
    echo "" >> ${QADIR}/BXH-XCEDE_EVAL.txt
    echo "" >> ${QADIR}/BXH-XCEDE_EVAL.txt

# -----------------------------------------------------------------------------------------------------------------------------------
# Print the outcome of the preceding step to make sure we got something
# -----------------------------------------------------------------------------------------------------------------------------------
cat ${QADIR}/BXH-XCEDE_EVAL.txt 

# -----------------------------------------------------------------------------------------------------------------------------------
# Now that the data are wrapped in BXH-XCEDE, generate the real QA data
# -----------------------------------------------------------------------------------------------------------------------------------
    ${progDir}/fmriqa_generate.pl --verbose ${QADIR}/BXHout_${i}.bxh ${QADIR}/${i}

done

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### End conditional for BXH-CEDE processes:
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
fi

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### If the functional data have not been converted from BXH, identify them and do the conversion (with reorientation):
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
FUNCDIR=${SUBJDIR}/Functional
if [ ! -d ${FUNCDIR} ]; then
mkdir -p ${FUNCDIR}

    BXH=`ls ${QADIR} | grep BXHout`
    counter=1;
    for i in ${BXH}; do
    mkdir -p ${FUNCDIR}/Run${counter}
    echo -e "Converting Run ${counter} from BXH to NIFTI................\n"
        ${progDir}/bxh2analyze -s --niigz ${QADIR}/${i} ${FUNCDIR}/Run${counter}/fmri
        fsl5.0-fslreorient2std ${FUNCDIR}/Run${counter}/fmri.nii.gz ${FUNCDIR}/Run${counter}/fmri.nii.gz
    counter=$((counter+1))
    done

fi

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Start to move anatomical data, if they have not been converted and moved.  For this, we'll use MRIcron to get the cropped 
#### images that are automatically generated.
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
ANATDIR=${SUBJDIR}/Anatomical
if [ ! -d ${ANATDIR} ]; then
mkdir -p ${ANATDIR}/T1/Extras
mkdir -p ${ANATDIR}/T2/Extras

    T1DIR=`ls ${RAWDATA} | grep MEMPRAGERMS`
    if [ -n "${T1DIR}" ]; then 
    dcm2nii -d n -e n -m n -r y -x y ${RAWDATA}/${T1DIR}
    mv ${RAWDATA}/${T1DIR}/*T1* ${ANATDIR}/T1/Extras
    tmpName=`ls ${ANATDIR}/T1/Extras/ | grep co`
    cp ${ANATDIR}/T1/Extras/${tmpName} ${ANATDIR}/T1/T1.nii.gz
    fi

    T1DIR=`ls ${RAWDATA} | grep T1_mprage`
    if [ -n "${T1DIR}" ]; then 
    dcm2nii -d n -e n -m n -r y -x y ${RAWDATA}/${T1DIR}
    mv ${RAWDATA}/${T1DIR}/*T1* ${ANATDIR}/T1/Extras
    cp ${ANATDIR}/T1/Extras/T1mprage.nii.gz ${ANATDIR}/T1/T1.nii.gz
    fi

    T2DIR=`ls ${RAWDATA} | grep T2_space`
    if [ -n "${T2DIR}" ]; then 
    dcm2nii -d n -e n -m n -r y -x y ${RAWDATA}/${T2DIR}
    mv ${RAWDATA}/${T2DIR}/*T2* ${ANATDIR}/T2/Extras
    cp ${ANATDIR}/T2/Extras/T2space.nii.gz ${ANATDIR}/T2/T2.nii.gz
    fi

fi

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Do the reorientation and brain extraction.  We will have a T1, but see if the T2 is present and we'll do both.  
###
##
# -----------------------------------------------------------------------------------------------------------------------------------

fsl5.0-fslreorient2std ${ANATDIR}/T1/T1.nii.gz ${ANATDIR}/T1/T1R.nii.gz
fsl5.0-bet ${ANATDIR}/T1/T1R.nii.gz ${ANATDIR}/T1/T1R_brain.nii.gz -B -f 0.5 -g 0 -R

if [ -e ${ANATDIR}/T2/T2.nii.gz ]; then
    fsl5.0-fslreorient2std ${ANATDIR}/T2/T2.nii.gz ${ANATDIR}/T2/T2R.nii.gz
    fsl5.0-bet ${ANATDIR}/T2/T2R.nii.gz ${ANATDIR}/T2/T2R_brain.nii.gz -B -f 0.5 -g 0 -R
fi

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Convert and move the fieldmap data and do the computations, though I'm not sure that we'll use them.  This is achieved through
#### the following steps:
#### 1) Create a skull-stripped brain mask using the modulus of the field map (MODbrain.nii).  This is used in FUGUE.
#### 2) Convert the phase data from the 12-bit integer format (scaled from 0 to 4095) to radians (measure of phase evolution 
#### between 2 echo times in the fieldmap acquisition).
#### 3) Use PRELUDE to unwrap the phase map (spins that evolve more than pi during the delta echo time cause discontinuities in the
#### fieldmap).
#### 4) Convert the unwrapped phase map into a fieldmap (in rad/s), by dividing by the delta echo-time from the fieldmap sequence. 
#### The delta TE in our sequence is 2.46ms.
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
FIELDDIR=${SUBJDIR}/Fmaps
if [ ! -d ${FIELDDIR} ]; then
mkdir -p ${FIELDDIR}/

# -----------------------------------------------------------------------------------------------------------------------------------
# Identify the mapping folders.  The mod will be the first and the phase will be the last:
# -----------------------------------------------------------------------------------------------------------------------------------
tmp=(`ls ${RAWDATA} | grep mapping`)

# -----------------------------------------------------------------------------------------------------------------------------------
# For the modulus:
# -----------------------------------------------------------------------------------------------------------------------------------
MODDIR=${tmp[0]}
dcm2nii -d n -e n -m n -r y -x y ${RAWDATA}/${MODDIR}
mv ${RAWDATA}/${MODDIR}/*.nii.gz ${FIELDDIR}/MOD.nii.gz
fsl5.0-bet ${FIELDDIR}/MOD.nii.gz ${FIELDDIR}/MODbrain.nii.gz -f 0.5 -m -R

# -----------------------------------------------------------------------------------------------------------------------------------
# For the pahse:
# -----------------------------------------------------------------------------------------------------------------------------------
PHASEDIR=${tmp[2]}
dcm2nii -d n -e n -m n -r y -x y ${RAWDATA}/${PHASEDIR}
mv ${RAWDATA}/${PHASEDIR}/*.nii.gz ${FIELDDIR}/Phase.nii.gz
fsl5.0-fslmaths ${FIELDDIR}/Phase.nii.gz -div 4096 -mul 3.14159 ${FIELDDIR}/PHASE_rad.nii.gz -odt float

# -----------------------------------------------------------------------------------------------------------------------------------
# Unwrap and convert to rads/sec:
# -----------------------------------------------------------------------------------------------------------------------------------
fsl5.0-prelude -p ${FIELDDIR}/PHASE_rad.nii.gz -a ${FIELDDIR}/MODbrain.nii.gz -m ${FIELDDIR}/MODbrain_mask.nii.gz -o ${FIELDDIR}/PHASE_rad_unwrapped.nii.gz
fsl5.0-fslmaths ${FIELDDIR}/PHASE_rad_unwrapped.nii.gz -div 0.00246 ${FIELDDIR}/FIELDmap_rads.nii.gz

fi

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Start the loop across runs...
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
FEATDIR=${SUBJDIR}/FEATdir
mkdir -p ${FEATDIR}

RUNS=`ls ${SUBJDIR}/Functional`
OUTDATA=${FSLDATADIR}/FSLoutput/Level1-PosNeg/${SUBJ}
RUNNUM=1 

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Begin setting replacement codes for the design files:
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
for i in ${RUNS}; do

if [ -d ${OUTDATA}/${i}.feat ]; then
echo -e "${i} of ${SUBJ} done -- moving on\n"

else

ANATFILE=${ANATDIR}/T1/T1R_brain.nii.gz
FUNDATA=${FUNCDIR}/${i}/fmri.nii.gz
B0MOD=${FIELDDIR}/MODbrain.nii.gz
B0FIELD=${FIELDDIR}/FIELDmap_rads.nii.gz
ONS1=${FSLDATADIR}/Onset-Files/`awk -v j=${RUNNUM} '{print $j}' /path/to/data/AandA/Onset-Files/${SUBJ}`1
ONS2=${FSLDATADIR}/Onset-Files/`awk -v j=${RUNNUM} '{print $j}' /path/to/data/AandA/Onset-Files/${SUBJ}`2
ONS3=${FSLDATADIR}/Onset-Files/`awk -v j=${RUNNUM} '{print $j}' /path/to/data/AandA/Onset-Files/${SUBJ}`3
ONS4=${FSLDATADIR}/Onset-Files/`awk -v j=${RUNNUM} '{print $j}' /path/to/data/AandA/Onset-Files/${SUBJ}`4
ONS5=${FSLDATADIR}/Onset-Files/All_`awk -v j=${RUNNUM} '{print $j}' /path/to/data/AandA/Onset-Files/${SUBJ}`
OUTDATA=${FSLDATADIR}/FSLoutput/Level1-PosNeg/${SUBJ}/${i}

echo -e "\nWe are working on Run $RUNNUM of $SUBJ\n"
echo -e "Output of this analysis can be found in $OUTDATA.feat\n"

	if [[ "$SUBJ" == "AA_001_20140303" ]] || [[ "$SUBJ" == "AA_002_20140303" ]]; then
	TRS=206
	else TRS=210
	fi 


				for ii in 'AandA_design3.fsf'; do
	
				sed -e 's@ANATFILE@'$ANATFILE'@g' \
    	    	    		    -e 's@FUNDATA@'$FUNDATA'@g' \
				    -e 's@B0FIELD@'$B0FIELD'@g' \
				    -e 's@B0MOD@'$B0MOD'@g' \
				    -e 's@ONS1@'$ONS1'@g' \
				    -e 's@ONS2@'$ONS2'@g' \
				    -e 's@ONS3@'$ONS3'@g' \
				    -e 's@ONS4@'$ONS4'@g' \
				    -e 's@ONS5@'$ONS5'@g' \
				    -e 's@TRS@'$TRS'@g' \
		    	    	    -e 's@OUTDATA@'$OUTDATA'@g' <$ii> ${FEATDIR}/FEAT_${i}.fsf
		
				done

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Run the job:
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
		fsl5.0-feat ${FEATDIR}/FEAT_${i}.fsf

# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### Create "run done" flag and update the run number:
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
		echo `date +%F_%T` > ${FSLDATADIR}/RunDone/${SUBJ}-${RUNNUM}--DONE.txt
		RUNNUM=$((RUNNUM+1))

		fi


# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### End loop across runs:
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
	done

# -----------------------------------------------------------------------------------------------------------------------------------
# Create "subject done" flag:
# -----------------------------------------------------------------------------------------------------------------------------------
echo `date +%F_%T` > ${FSLDATADIR}/SubDone/${SUBJ}--DONE.txt


# -----------------------------------------------------------------------------------------------------------------------------------
##
###
#### End loop across subjects:
###
##
# -----------------------------------------------------------------------------------------------------------------------------------
done


#`awk -v j=${RUNNUM} '{print $j}' /path/to/data/AandA/SubjectData/AA_001_20140303/Onsets/order`1
#
#echo a b c d > /path/to/data/AandA/Onset-Files/AA_001_20140303
#echo a b c e > /path/to/data/AandA/Onset-Files/AA_002_20140303
#echo a c d e > /path/to/data/AandA/Onset-Files/AA_003_20140305
#echo a b d e > /path/to/data/AandA/Onset-Files/AA_004_20140305
#echo a b c d > /path/to/data/AandA/Onset-Files/AA_005_20140305
#echo a c d e > /path/to/data/AandA/Onset-Files/AA_006_20140305 
#echo a b d e > /path/to/data/AandA/Onset-Files/AA_007_20140306
#echo a b c e > /path/to/data/AandA/Onset-Files/AA_008_20140306
#echo b c d e > /path/to/data/AandA/Onset-Files/AA_009_20140306
#echo a b d e > /path/to/data/AandA/Onset-Files/AA_010_20140311 
#echo b c d e > /path/to/data/AandA/Onset-Files/AA_011_20140311
#echo a b c d > /path/to/data/AandA/Onset-Files/AA_012_20140313
#echo d c b e > /path/to/data/AandA/Onset-Files/AA_013_20140313
#echo e b c a > /path/to/data/AandA/Onset-Files/AA_014_20140314
#echo d c a e > /path/to/data/AandA/Onset-Files/AA_015_20140314
#echo e b d a > /path/to/data/AandA/Onset-Files/AA_016_20140314


#echo ${array[@]} | awk 'BEGIN{RS=" ";} {print $1}' | sort -n

#ls -d1 /path/to/data/AandA/DICOM/* | grep *.nii

#if [ ! -d ${OUTDATA}/${i}.feat ]; then
#echo -e "nope"
#fi



