setenv SUBJECTS_DIR /path/to/data/MizellefMRI/FS-recon
set dtroot = /path/to/data/MizellefMRI/FS-recon
set subjlist = (pilot_03_20130829)
set dcmroot = /path/to/data/MizellefMRI/pilot_03_20130829
set dcmlist = (DTIFiles/DTI_D1D2.nii.gz)
set runlist = (1)
set bvecfile = /path/to/data/MizellefMRI/pilot_03_20130829/DTIFiles/configFiles/bvecs
set bvalfile = /path/to/data/MizellefMRI/pilot_03_20130829/DTIFiles/configFiles/bvals
set dob0 = 0
set b0mlist = (/00001.dcm)
set b0plist = (/00001.dcm)
set nb0 = 10
set echospacing = 0.0008
set doeddy = 1
set dorotbvecs = 1
set thrbet = 0.5
set doregflt = 1
set doregbbr = 1
set doregmni = 1
set mnitemp = /usr/share/fsl/5.0/data/standard/MNI152_T1_1mm_brain.nii.gz
set doregcvs = 1
set cvstemp = cvs_avg35_inMNI152
set cvstempdir = /usr/local/freesurfer/subjects
set usemaskanat = 1
set pathlist = (lh.cst_AS rh.cst_AS \ 
          	      lh.unc_AS rh.unc_AS \ 
          	      lh.ilf_AS rh.ilf_AS \ 
          	      fmajor_PP fminor_PP \ 
          	      lh.atr_PP rh.atr_PP \ 
          	      lh.ccg_PP rh.ccg_PP \ 
          	      lh.cab_PP rh.cab_PP \ 
          	      lh.slfp_PP rh.slfp_PP \ 
          	      lh.unc_AS rh.unc_AS \ 
          	      lh.slft_PP rh.slft_PP) 
set trainfile = /usr/local/freesurfer/trctrain/trainlist.txt
set nstick = 2
set nburnin = 200
set nsample = 7500
set nkeep = 5
set reinit = 0
