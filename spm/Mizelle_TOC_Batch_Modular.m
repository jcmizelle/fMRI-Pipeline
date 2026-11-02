function Mizelle_TOC_Batch_Modular(subjects);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% J.C. Mizelle
% 12/30/2009
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script assumes that the data files have been previously converted
% from DICOM format and are in some form of the following organization:
%
%   Experiment
%       |_____ Subject 1
%       |         |_____ Anatomical
%       |         |_____ Functional
%       |                    |_____ Session1
%       |                    |_____ Session2
%       |                    |_____ ...
%       |_____ Subject 2
%       |_____  ...
%
%
% This script will perform the following steps on a per-subject basis
% across individual sessions:
%
%  * Slice Time Corection
%  * Realign:    estimate and reslice (mean and all images)
%  * Coregister: estimate only (structural -> mean functional)
%  * Segment
%  * Normalize:  write (functional and anatomical)
%  * Smooth
%
% A grand-mean normalized structural image is created as a final step
%
% This script is dependent on editfilenames.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set Directories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Change to Parent Directory 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd '/path/to/data/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set Paths for Functional and Anatomical data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_path1 = ['/path/to/data/'];
data_path2 = ['/DICOM/Data/Functional'];
data_path3 = ['/DICOM/Data/Anatomical'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Identify Subjects Folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%subjects = {'TOC002' 'TOC003' 'TOC004'};
%subjects = {'TOC001'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Identify Folders for Individual Experimental Runs (Session Folders)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sessions = {'Session 1' 'Session 2' 'Session 3' 'Session 4' 'Session 5' 'Session 6'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialise SPM Defaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spm('Defaults','fMRI');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set to Loop Over Subjects 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:numel(subjects);
    
    disp(['---------------------------->>>            ' ...;
    'Preprocessing subject ' subjects{i}]);



%Mizelle_art_repair(subjects(i));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Prepare Workspace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    clear jobs a f 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Concatenate Subject-Specific Functional and Anatomical Folders
%
%   Build List of Files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for j=1:numel(sessions)
        %f{j} = spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^ghfmri.*\.img$');
        f{j} = spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^fmri.*\.img$');
        
    end

    a = spm_select('FPList', fullfile(data_path1,subjects{i},data_path3), '^t1MPRAGE.*\.img$');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEMPORAL PREPROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp(['Slice Timing: Correct for differences in image acquisition time betwen slices ']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loop over sessions to assign data to structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %jobs{1}.spm.temporal.st
    for j=1:numel(sessions)
        jobs{1}.spm.temporal{1}.st.scans{j} = cellstr(f{j});
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Build jobs structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    jobs{1}.spm.temporal{1}.st.nslices = 37;
    jobs{1}.spm.temporal{1}.st.tr = 2.0;
    jobs{1}.spm.temporal{1}.st.ta = 2.0-(2.0/37.0);
    jobs{1}.spm.temporal{1}.st.so = [1:1:37];
    jobs{1}.spm.temporal{1}.st.refslice = 37;
    jobs{1}.spm.temporal{1}.st.prefix = 'a';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    data_path4 = ['/DICOM/Data/'];
    save(fullfile(data_path1,subjects{i},data_path4,'preprocessing_slicetiming.mat'),'jobs');
    spm_jobman('run',jobs); 

    disp(['---------------------------->>>       ' ...;
    'Slice Timing Complete: Subject ' subjects{i} '       <<<----------------------------']);

    clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SPATIAL PREPROCESSING - REALIGN: ESTIMATE AND RESLICE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp(['Realign: Estimate and Reslice for MEAN and ALL images ']);

    %jobs{1}.spm.spatial.realign.estwrite.data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loop over sessions to assign data to structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for j=1:numel(sessions);
        jobs{1}.spm.spatial{1}.realign.estwrite.data{j} = cellstr(editfilenames(f{j},'prefix','a'));
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Build jobs structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %jobs{1}.spm.spatial.realign.estwrite.eoptions
    jobs{1}.spm.spatial{1}.realign.estwrite.eoptions.quality = 1;
    jobs{1}.spm.spatial{1}.realign.estwrite.eoptions.sep = 2;
    jobs{1}.spm.spatial{1}.realign.estwrite.eoptions.fwhm = 5;
    jobs{1}.spm.spatial{1}.realign.estwrite.eoptions.rtm = 1;
    jobs{1}.spm.spatial{1}.realign.estwrite.eoptions.interp = 5;
    jobs{1}.spm.spatial{1}.realign.estwrite.eoptions.wrap = [0 0 0];
    jobs{1}.spm.spatial{1}.realign.estwrite.eoptions.weight = {}; 

    %jobs{1}.spm.spatial.realign.estwrite.roptions
    jobs{1}.spm.spatial{1}.realign.estwrite.roptions.which = [2 1];
    jobs{1}.spm.spatial{1}.realign.estwrite.roptions.interp = 5;
    jobs{1}.spm.spatial{1}.realign.estwrite.roptions.wrap = [0 0 0];
    jobs{1}.spm.spatial{1}.realign.estwrite.roptions.mask = 1;
    jobs{1}.spm.spatial{1}.realign.estwrite.roptions.prefix = 'r';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    data_path4 = ['/DICOM/Data/'];
    save(fullfile(data_path1,subjects{i},data_path4,'preprocessing_realign.mat'),'jobs');
    spm_jobman('run',jobs);

    disp(['---------------------------->>>       ' ...;
    'Realignment Complete: Subject ' subjects{i} '       <<<----------------------------']);

    clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SPATIAL PREPROCESSING - COREGISTER: structural --> mean functional
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    disp(['Coregistration: Estimate structural image (change postition file (.hdr) to match postition of mean functional image) ']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Build jobs structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %jobs{1}.spm.spatial{1}.coreg.estimate
    jobs{1}.spm.spatial{1}.coreg.estimate.ref = editfilenames(f{1}(1,:),'prefix','meana');
    jobs{1}.spm.spatial{1}.coreg.estimate.source = cellstr(a);
    jobs{1}.spm.spatial{1}.coreg.estimate.other = {''};
    jobs{1}.spm.spatial{1}.coreg.estimate.eoptions.cost_fun = 'nmi';
    jobs{1}.spm.spatial{1}.coreg.estimate.eoptions.sep = [4 2];
    jobs{1}.spm.spatial{1}.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    jobs{1}.spm.spatial{1}.coreg.estimate.eoptions.fwhm = [7 7];
    % jobs{1}.spm.spatial{1}.coreg.estimate.roptions.interp = 1;
    % jobs{1}.spm.spatial{1}.coreg.estimate.roptions.wrap = [0 0 0];
    % jobs{1}.spm.spatial{1}.coreg.estimate.roptions.mask = 0;
    % jobs{1}.spm.spatial{1}.coreg.estimate.roptions.prefix = 'c';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    data_path4 = ['/DICOM/Data/'];
    save(fullfile(data_path1,subjects{i},data_path4,'preprocessing_coregister.mat'),'jobs');
    spm_jobman('run',jobs); 

    disp(['---------------------------->>>       ' ...;
    'Coregistration Complete: Subject ' subjects{i} '       <<<----------------------------']);

    clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SPATIAL PREPROCESSING - SEGMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp(['Segmentation: Produce gray matter (native & modulated normalized) & withe matter (native) from structural image ']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Build jobs structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %jobs{1}.spm.spatial{1}.preproc.data
    jobs{1}.spm.spatial{1}.preproc.data = cellstr(a);

    %jobs{1}.spm.spatial{1}.preproc.output
    jobs{1}.spm.spatial{1}.preproc.output.GM = [0 0 1];
    jobs{1}.spm.spatial{1}.preproc.output.WM = [0 0 1];
    jobs{1}.spm.spatial{1}.preproc.output.CSF = [0 0 0];
    jobs{1}.spm.spatial{1}.preproc.output.biascor = 1;
    jobs{1}.spm.spatial{1}.preproc.output.cleanup = 0;

    %jobs{1}.spm.spatial{1}.preproc.opts
    jobs{1}.spm.spatial{1}.preproc.opts.tpm = { ...;
        '/path/to/Matlab Software/spm8/tpm/grey.nii' ...;
        '/path/to/Matlab Software/spm8/tpm/white.nii' ...;
        '/path/to/Matlab Software/spm8/tpm/csf.nii' ...;
        };
    jobs{1}.spm.spatial{1}.preproc.opts.ngaus = [2 2 2 4];
    jobs{1}.spm.spatial{1}.preproc.opts.regtype = 'mni';
    jobs{1}.spm.spatial{1}.preproc.opts.warpreg = 1;
    jobs{1}.spm.spatial{1}.preproc.opts.warpco = 25;
    jobs{1}.spm.spatial{1}.preproc.opts.biasreg = 0.0001;
    jobs{1}.spm.spatial{1}.preproc.opts.biasfwhm = 60;
    jobs{1}.spm.spatial{1}.preproc.opts.samp = 3;
    jobs{1}.spm.spatial{1}.preproc.opts.msk = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    data_path4 = ['/DICOM/Data/'];
    save(fullfile(data_path1,subjects{i},data_path4,'preprocessing_segment.mat'),'jobs');
    spm_jobman('run',jobs); 

    disp(['---------------------------->>>       ' ...;
    'Segmentation Complete: Subject ' subjects{i} '       <<<----------------------------']);

    clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SPATIAL PREPROCESSING - NORMALIZE FUNCTIONAL AND ANATOMICAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp(['Normalize: Applying previously estimated warps to FUNCTIONAL and ANATOMICAL images ']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    % Functional Normalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Build jobs structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %jobs{5}.spm.spatial{1}.normalise.write.subj
    jobs{1}.spm.spatial{1}.normalise{1}.write.subj.matname = editfilenames(a,'suffix','_seg_sn','ext','.mat');
    jobs{1}.spm.spatial{1}.normalise{1}.write.subj.wtsrc = {};
    jobs{1}.spm.spatial{1}.normalise{1}.write.subj.resample = editfilenames(char(f),'prefix','ra');

    %jobs{1}.spm.spatial.normalise.write.roptions
    jobs{1}.spm.spatial{1}.normalise{1}.write.roptions.preserve = 0;
    jobs{1}.spm.spatial{1}.normalise{1}.write.roptions.bb = [-78 -112 -70;78 76 90];
    jobs{1}.spm.spatial{1}.normalise{1}.write.roptions.vox = [3 3 3];
    jobs{1}.spm.spatial{1}.normalise{1}.write.roptions.interp = 5;
    jobs{1}.spm.spatial{1}.normalise{1}.write.roptions.wrap = [0 0 0];
    jobs{1}.spm.spatial{1}.normalise{1}.write.roptions.prefix = 'w';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    data_path4 = ['/DICOM/Data/'];
    save(fullfile(data_path1,subjects{i},data_path4,'preprocessing_normalise_fun.mat'),'jobs');
    spm_jobman('run',jobs);

    disp(['---------------------------->>>       ' ...;
    'Functional Normalization Complete: Subject ' subjects{i} '       <<<----------------------------']);

    clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % Anatomical Normalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Build jobs structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %jobs{1}.spm.spatial.normalise.write.subj
    jobs{1}.spm.spatial{1}.normalise{1}.write.subj.matname = editfilenames(a,'suffix','_seg_sn','ext','.mat');
    jobs{1}.spm.spatial{1}.normalise{1}.write.subj.wtsrc = {};
    jobs{1}.spm.spatial{1}.normalise{1}.write.subj.resample = cellstr(editfilenames(a,'prefix','m'));

    %jobs{1}.spm.spatial.normalise.write.roptions
    jobs{1}.spm.spatial{1}.normalise{1}.write.roptions.preserve = 0;
    jobs{1}.spm.spatial{1}.normalise{1}.write.roptions.bb = [-78 -112 -70;78 76 90];
    jobs{1}.spm.spatial{1}.normalise{1}.write.roptions.vox = [1 1 1];
    jobs{1}.spm.spatial{1}.normalise{1}.write.roptions.interp = 5;
    jobs{1}.spm.spatial{1}.normalise{1}.write.roptions.wrap = [0 0 0];
    jobs{1}.spm.spatial{1}.normalise{1}.write.roptions.prefix = 'w';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    data_path4 = ['/DICOM/Data/'];
    save(fullfile(data_path1,subjects{i},data_path4,'preprocessing_normalise_anat.mat'),'jobs');
    spm_jobman('run',jobs);

    disp(['---------------------------->>>       ' ...;
    'Anatomical Normalization Complete: Subject ' subjects{i} '       <<<----------------------------']);

    clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SPATIAL PREPROCESSING - SMOOTH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp(['Smoothing: Convolving images to suppress noise and other effects of differences in functional and gyral anatomy ']);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Build jobs structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    %jobs{1}.spm.spatial.smooth
    jobs{1}.spm.spatial{1}.smooth.data = editfilenames(char(f),'prefix','wra');
    jobs{1}.spm.spatial{1}.smooth.fhm = [8 8 8];
    jobs{1}.spm.spatial{1}.smooth.dtype = 0; 
    jobs{1}.spm.spatial{1}.smooth.prefix = 's';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    data_path4 = ['/DICOM/Data/'];
    save(fullfile(data_path1,subjects{i},data_path4,'preprocessing_smooth.mat'),'jobs');
    spm_jobman('run',jobs);   

    disp(['---------------------------->>>       ' ...;
    'Smoothing Complete: Subject ' subjects{i} '       <<<----------------------------']);




%Mizelle_art_global(subjects(i));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Subject Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create mean structural image of ALL subjects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear jobs a
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %    Loop over subjects to assign data to structure
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% subjects2 = ([{'TOC001' 'TOC002' 'TOC003' 'TOC004' 'TOC005' 'TOC007' 'TOC008' 'TOC009' 'TOC010' 'TOC011' 'TOC012' 'TOC013' 'TOC014' 'TOC015'}]);
% 
% for i=1:length(subjects2);
%     
%   anatdir = (fullfile(data_path1,subjects2{i},data_path3));
%   a{i} = spm_select('FPList', anatdir, '^wm.*\.img$'); % warped modulated
% 
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %    Build jobs structure
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% jobs{1}.util{1}.imcalc.input = a;
% jobs{1}.util{1}.imcalc.output = fullfile(data_path1,'mean_anat.img');
% jobs{1}.util{1}.imcalc.expression = 'mean(X)';
% jobs{1}.util{1}.imcalc.options.dmtx = 1;
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %    Save and run module
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% data_path4 = ['/DICOM/Data/'];
% save(fullfile(data_path1,'mean_image.mat'),'jobs');
% spm_jobman('run',jobs);   
% 
% disp(['---------------------------->>>       ' ...;
% 'Mean Image Complete       <<<----------------------------']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End of File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

