# fMRI / DTI analysis pipeline (FSL, FreeSurfer, SPM)

Batch scripts for task-fMRI and diffusion analysis written by J.C. (Chris) Mizelle, PhD, for studies of tool use, action understanding, and sensorimotor control at Georgia Tech and the Atlanta VA (2009-2015). Two generations are included: an SPM/MATLAB batch system (2009-2011) and a Bash/FSL/FreeSurfer pipeline (2011-2015).

## FSL first-level pipeline (`fsl/first_level/`)
One script per study, built from a common template. Run with subject folder names as arguments:
```
./AU_firstlevel_batch.sh AU_003_20120621 AU_004_20120628 ...
```
For each subject it:
1. Converts DICOM to NIfTI (`dcm2nii`) and runs BXH-XCEDE quality reports. The small helper scripts for that step (`Running_BXH-XCEDE` and related) were not preserved; the call is left in place and the step can be skipped or replaced with your QA tool of choice.
2. Checks that required inputs exist (T1/T2 anatomicals, functional runs, B0 fieldmap magnitude/phase, onset files) and skips the subject with a report if anything is missing.
3. Standardizes the folder layout (Anatomical, Functional, Fmaps, FEATdir) and reorients images to FSL convention (`fslreorient2std`).
4. Brain-extracts anatomicals (`bet -R -B`).
5. Prepares B0 fieldmap unwarping: skull-strips the magnitude image, rescales the phase image to radians, unwraps it with `prelude`, and converts it to rad/s (delta TE 2.46 ms) for FUGUE (dwell time 0.49 ms).
6. Sets up registration inside FEAT: functional to structural (FLIRT) and structural to MNI152 (FNIRT), using the brain-extracted T1 from step 4.
7. Writes a per-run `design.fsf` from the study template (`*_design_template.fsf`) by `sed` substitution of capitalized placeholders, then runs `feat`.
8. Writes run- and subject-level completion flags so an interrupted batch restarts where it stopped.

`AandA_firstlevel_batch.sh` (2014) is a later, leaner version of the same template.

## Higher-level analysis (`fsl/second_level/`, `fsl/group_utils/`)
- Level 2 fixed-effects across runs (pre/post sessions), driven by `.fsf` templates.
- Conjunction analysis by minimum statistic (`fslmaths -min`) with cluster thresholding (z > 2.3, cluster p < .05).
- Cluster reporting and peak-coordinate extraction, subtraction contrasts, group masks, and a seed-based PPI time-series extraction script.

## Diffusion (`diffusion/`)
TRACULA configuration (FreeSurfer) for probabilistic tractography: eddy-current correction, b-vector rotation, FLIRT/BBR registration, MNI and CVS normalization, and 18 major tracts (corticospinal, uncinate, ILF, forceps major/minor, anterior thalamic radiation, cingulum).

## SPM batch system (`spm/`)
MATLAB batch scripts (SPM5/SPM8) for first-level models, second-level statistics, conjunctions, and a modular parent script, plus ArtRepair-based artifact detection and repair (`Mizelle_art_global.m`, adapted from Paul Mazaika's ArtRepair toolbox; original credits retained in the file).

## Requirements
FSL 4/5, FreeSurfer 5.x (TRACULA), dcm2nii (MRIcron), BXH/XCEDE tools, MATLAB with SPM5/SPM8 and ArtRepair.

## Notes
- Paths are placeholders (`/path/to/...`); set them for your system.
- No imaging data are included.
- These are working research scripts, kept close to how they ran.

## License
GPL-3.0. See LICENSE.
