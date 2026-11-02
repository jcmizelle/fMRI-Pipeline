function Mizelle_TOC_Batch_First_Level(subjects);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% J.C. Mizelle
% 12/30/2009
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script should be executed following the preprocessing steps as 
% outlined in Mizelle_TOC_Batch_Modular.m. This script performs first-level 
% analysis for all subjects identified on a per-subject basis across 
% individual sessions.  Data should be organized similarly to that shown
% below:
%
%   Experiment
%       |_____ Subject 1
%       |_________ Statistics
%       |_________ Data
%       |         |_____ Anatomical
%       |         |_____ Functional
%       |                    |_____ Session1
%       |                    |_____ Session2
%       |                    |_____ ...
%       |_____ Subject 2
%       |_____  ...
%
%
% For each subject, the GLM model is specified and esimated, and a list of 
% specific t- and f-contrasts is computed and saved into that subject's
% stats output folder for later use in second level analysis.
%
% This script also calls editfilenames.m 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Purge Matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pause(2.0)
clear jobs 
clc

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
%% Identify Folders for Individual Experimental Runs (Sessions Folders)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sessions = {'Session 1' 'Session 2' 'Session 3' 'Session 4' 'Session 5' 'Session 6'};
%subjects = {'TOC002' 'TOC003' 'TOC004'};
%subjects = {'TOC006'};
condnames = {'Correct' 'Context' 'Tool' 'Hand'};% 'Fixation'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define Paths for Stats Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_path5 = ['/path/to/data/'];
data_path6 = ['/DICOM/Stats/Categorical'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialise SPM Defaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spm('Defaults','fMRI');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Event Onsets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load(fullfile(data_path5,'TOC_onsets.mat'));
%load(fullfile(data_path5,'TOC2.mat'));
load(fullfile(data_path5,'TOC2_2.mat'));
%load(fullfile(data_path5,'TOC3.mat'));
load(fullfile(data_path5,'TOC3_2.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set to Loop Over Subjects 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:numel(subjects);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create Directories if Needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if (exist(fullfile(data_path5,subjects{i},data_path6)) == 0)
       mkdir (fullfile(data_path5,subjects{i},data_path6));
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Concatenate Subject-Specific Functional and Anatomical Folders
%
%   Build List of Files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for j=1:numel(sessions)
        f{j} = spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^fmri.*\.img$');
    end

    a = spm_select('FPList', fullfile(data_path1,subjects{i},data_path3), '^t1MPRAGE.*\.img$');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MODEL SPECIFICATION AND ESTIMATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize jobs structure and set general configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    jobs{1}.util{1}.md.basedir = cellstr(fullfile(data_path1));
    jobs{1}.util{1}.md.name = 'Categorical';

    jobs{2}.stats{1}.fmri_spec.dir = cellstr(fullfile(data_path5,subjects{i},data_path6));
    jobs{2}.stats{1}.fmri_spec.timing.units = 'scans';
    jobs{2}.stats{1}.fmri_spec.timing.RT = 2;
    jobs{2}.stats{1}.fmri_spec.timing.fmri_t = 16;
    jobs{2}.stats{1}.fmri_spec.timing.fmri_t0 = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set to loop over sessions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for j=1:numel(sessions)

        %jobs{2}.stats{1}.fmri_spec.sess(j).scans = editfilenames(char(f{j}),'prefix','vswragh');
        jobs{2}.stats{1}.fmri_spec.sess(j).scans = editfilenames(char(f{j}),'prefix','swra');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Set to loop over conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        for k=1:numel(condnames)

            jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).name = condnames{k};
            %jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).onset = TOC.onsets{k};
            
            if strfind('TOC002',subjects{i}) == 1;
                
                jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).onset = TOC2.onsets{k};
                
            elseif strfind('TOC003',subjects{i}) == 1;
                
                jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).onset = TOC2.onsets{k};
                
            elseif strfind('TOC004',subjects{i}) == 1;
                
                jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).onset = TOC2.onsets{k};
                
            elseif strfind('TOC006',subjects{i}) == 1;
                
                jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).onset = TOC2.onsets{k};
                
            else
                
                jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).onset = TOC3(j).onsets{k};
            
            end
            
            jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).duration = 0;
            jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).tmod = 0;    
            jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).mod = struct('name', {}, 'param', {}, 'poly', {});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % End condition loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        end

        %jobs{2}.stats{1}.fmri_spec.sess(j).multi_reg = editfilenames(char(f{j}(1,:)),'prefix','rp_agh','ext','.txt');
        jobs{2}.stats{1}.fmri_spec.sess(j).multi_reg = editfilenames(char(f{j}(1,:)),'prefix','rp_a','ext','.txt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % End session loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

    jobs{2}.stats{1}.fmri_spec.fact = struct('name', {''}, 'levels', {});
    jobs{2}.stats{1}.fmri_spec.bases.hrf.derivs = [0 0];
    jobs{2}.stats{1}.fmri_spec.volt = 1;
    jobs{2}.stats{1}.fmri_spec.global = 'None';
    jobs{2}.stats{1}.fmri_spec.mask = {''};
    jobs{2}.stats{1}.fmri_spec.cvi = 'AR(1)';

    jobs{3}.stats{1}.fmri_est.spmmat = cellstr(fullfile(data_path5,subjects{i},data_path6,'SPM.mat'));
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    save(fullfile(data_path5,subjects{i},data_path6,'first_level_model.mat'),'jobs');
    spm_jobman('run',jobs);

    clear jobs
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End subject loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purge jobs structure from memory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INFERENCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create list of desired contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

contrasts = {...   
    'Correct',...
    'Incorrect',...
    'Tool',...
    'Hand',...
    'All_vs_Baseline',...
    'Baseline_vs_All',...
    'Correct_vs_Incorrect',...
    'Incorrect_vs_Correct'...
    'Correct_vs_Tool',...
    'Tool_vs_Correct'...
    'Correct_vs_Hand',...
    'Hand_vs_Correct'...
    'Incorrect_vs_Tool',...
    'Tool_vs_Incorrect'...
    'Incorrect_vs_Hand',...
    'Hand_vs_Incorrect'...
    'Tool_vs_Hand',...
    'Hand_vs_Tool'...
    };

fcontrast = {'F-Test'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create vectors for t-contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create 4*n matrix for condition contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tcont = [eye(4) zeros(4,7)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create unique vectors for t-contrasts with respect to list of contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tcont = [tcont;1 1 1 1 0 0 0 0 0 0 0];
tcont = [tcont;-1 -1 -1 -1 0 0 0 0 0 0 0];
tcont = [tcont;1 -1 0 0 0 0 0 0 0 0 0];
tcont = [tcont;-1 1 0 0 0 0 0 0 0 0 0];
tcont = [tcont;1 0 -1 0 0 0 0 0 0 0 0];
tcont = [tcont;-1 0 1 0 0 0 0 0 0 0 0];
tcont = [tcont;1 0 0 -1 0 0 0 0 0 0 0];
tcont = [tcont;-1 0 0 1 0 0 0 0 0 0 0];
tcont = [tcont;0 1 -1 0 0 0 0 0 0 0 0];
tcont = [tcont;0 -1 1 0 0 0 0 0 0 0 0];
tcont = [tcont;0 1 0 -1 0 0 0 0 0 0 0];
tcont = [tcont;0 -1 0 1 0 0 0 0 0 0 0];
tcont = [tcont;0 0 1 -1 0 0 0 0 0 0 0];
tcont = [tcont;0 0 -1 1 0 0 0 0 0 0 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create vectors for f-contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fcont = [eye(4) zeros(4,7)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alternative use: To Model HRF + Derivatives - above make sure to set
% jobs{2}.stats{1}.fmri_spec.bases.hrf.derivs = [1 1]; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % 
% % % % tcont = [kron(eye(4),[1 1 1]) zeros(4,7)];
% % % % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create unique vectors for t-contrasts with respect to list of contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % 
% % % % tcont = [tcont;repmat([1 0 0],1,4) zeros(1,7)];
% % % % tcont = [tcont;1 zeros(1,2) -1 zeros(1,2) zeros(1,6) zeros(1,7)];
% % % % tcont = [tcont;-1 zeros(1,2) 1 zeros(1,2) zeros(1,6) zeros(1,7)];
% % % % tcont = [tcont;1 zeros(1,2) zeros(1,3) -1 zeros(1,2) zeros(1,3) zeros(1,7)];
% % % % tcont = [tcont;-1 zeros(1,2) zeros(1,3) 1 zeros(1,2) zeros(1,3) zeros(1,7)];
% % % % tcont = [tcont;1 zeros(1,2) zeros(1,6) -1 zeros(1,2) zeros(1,7)];
% % % % tcont = [tcont;-1 zeros(1,2) zeros(1,6) 1 zeros(1,2) zeros(1,7)];
% % % % tcont = [tcont;zeros(1,3) 1 zeros(1,2) -1 zeros(1,2) zeros(1,3) zeros(1,7)];
% % % % tcont = [tcont;zeros(1,3) -1 zeros(1,2) 1 zeros(1,2) zeros(1,3) zeros(1,7)];
% % % % tcont = [tcont;zeros(1,3) 1 zeros(1,2) zeros(1,3) -1 zeros(1,2) zeros(1,7)];
% % % % tcont = [tcont;zeros(1,3) -1 zeros(1,2) zeros(1,3) 1 zeros(1,2) zeros(1,7)];
% % % % tcont = [tcont;zeros(1,6) 1 zeros(1,2) -1 zeros(1,2) zeros(1,7)];
% % % % tcont = [tcont;zeros(1,6) -1 zeros(1,2) 1 zeros(1,2) zeros(1,7)];
% % % % 
% % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % % Create vectors for f-contrasts
% % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % 
% % % % % fcont = [ones(1,3) zeros(1,9)];
% % % % % fcont = [fcont; zeros(1,3) ones(1,3) zeros(1,6)];
% % % % % fcont = [fcont; zeros(1,6) ones(1,3) zeros(1,3)];
% % % % % fcont = [fcont; zeros(1,9) ones(1,3)];
% % % % fcont = [zeros(4,19)];
% % % % fcont(:,1:12) = kron(eye(4),[1 0 0]);
% % % % 
% % % % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End alternative use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set to Loop Over Subjects 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1 : numel(subjects)

    clear jobs 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set to Loop Over Contrasts 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    for cont_nr = 1:numel(contrasts);
        
        contrasttype = contrasts{cont_nr};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        % Enter contasts here - loop through vectors for t-contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
        contr_input = tcont(cont_nr,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        % Set up job structure for contrasts (t-contrasts here)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(data_path5,subjects{i},data_path6,'SPM.mat'));
        jobs{1}.stats{1}.con.consess{1}.tcon.name = contrasttype;
        jobs{1}.stats{1}.con.consess{1}.tcon.convec = contr_input;
        jobs{1}.stats{1}.con.consess{1}.tcon.sessrep = 'repl';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        % Make sure NOT to overwrite existing contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        jobs{1}.stats{1}.con.delete = 0; 
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
        disp(['RUNNING ' contrasts{cont_nr} ' contrast specification for subject number  ' subjects{1,i}]);
        spm_jobman('run',jobs);
        
        disp(['"' contrasts{cont_nr} '"' ' t-contrast created for subject number  ' subjects{1,i}]);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % End Contrast Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
    
    end
    
    disp(['------------>>>       All T-contrasts created']);

    clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    % Set up job structure for contrasts (f-contrasts here)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(data_path5,subjects{i},data_path6,'SPM.mat'));
    jobs{1}.stats{1}.con.consess{1}.fcon.name = char(fcontrast);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loop to index vector(s) for f-contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for k=1:size(fcont,1);
        jobs{1}.stats{1}.con.consess{1}.fcon.convec{1,k} = fcont(k,:);
    end

    jobs{1}.stats{1}.con.consess{1}.fcon.sessrep = 'repl';
    jobs{1}.stats{1}.con.delete = 0;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    disp(['RUNNING f-contrast specification for subject number  ' subjects{1,i}]);
    spm_jobman('run',jobs); 

    disp(['F-contasts created']);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Subject Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End Of Individual Contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
%
% Begin creating contrasts for Second Level Model with an informed basis 
% set.  This requires individual con*.img files for the canonical HRF basis
% function as well as its two partial derivatives with respect to time and 
% dispersion. 
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Purge Matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pause(2.0)
clear contrasttype contr_input fcont tcont contrasts jobs 
clc

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
%% Identify Folders for Individual Experimental Runs (Sessions Folders)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sessions = {'Session 1' 'Session 2' 'Session 3' 'Session 4' 'Session 5' 'Session 6'};
%subjects = {'TOC002' 'TOC003' 'TOC004'};
%subjects = {'TOC006'};
condnames = {'Correct' 'Context' 'Tool' 'Hand'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define Paths for Stats Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_path5 = ['/path/to/data/'];
data_path6 = ['/DICOM/Stats/Categorical/Second Level Contrasts'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialise SPM Defaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spm('Defaults','fMRI');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Event Onsets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load(fullfile(data_path5,'TOC_onsets.mat'));
load(fullfile(data_path5,'TOC2.mat'));
load(fullfile(data_path5,'TOC3.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set to Loop Over Subjects 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:numel(subjects);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create Directories if Needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if (exist(fullfile(data_path5,subjects{i},data_path6)) == 0)
       mkdir (fullfile(data_path5,subjects{i},data_path6));
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Concatenate Subject-Specific Functional and Anatomical Folders
%
%   Build List of Files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for j=1:numel(sessions)
        f{j} = spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^fmri.*\.img$');
    end

    a = spm_select('FPList', fullfile(data_path1,subjects{i},data_path3), '^t1MPRAGE.*\.img$');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MODEL SPECIFICATION AND ESTIMATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize jobs structure and set general configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    jobs{1}.util{1}.md.basedir = cellstr(fullfile(data_path1));
    jobs{1}.util{1}.md.name = 'Categorical';

    jobs{2}.stats{1}.fmri_spec.dir = cellstr(fullfile(data_path5,subjects{i},data_path6));
    jobs{2}.stats{1}.fmri_spec.timing.units = 'scans';
    jobs{2}.stats{1}.fmri_spec.timing.RT = 2;
    jobs{2}.stats{1}.fmri_spec.timing.fmri_t = 16;
    jobs{2}.stats{1}.fmri_spec.timing.fmri_t0 = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set to loop over sessions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for j=1:numel(sessions)

        %jobs{2}.stats{1}.fmri_spec.sess(j).scans = editfilenames(char(f{j}),'prefix','vswragh');
        jobs{2}.stats{1}.fmri_spec.sess(j).scans = editfilenames(char(f{j}),'prefix','swra');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Set to loop over conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        for k=1:numel(condnames)

            jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).name = condnames{k};
            %jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).onset = TOC.onsets{k};
            
            if strfind('TOC002',subjects{i}) == 1;
                
                jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).onset = TOC2.onsets{k};
                
            elseif strfind('TOC003',subjects{i}) == 1;
                
                jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).onset = TOC2.onsets{k};
                
            elseif strfind('TOC004',subjects{i}) == 1;
                
                jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).onset = TOC2.onsets{k};
                
            elseif strfind('TOC006',subjects{i}) == 1;
                
                jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).onset = TOC2.onsets{k};                
                
            else
                
                jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).onset = TOC3(j).onsets{k};
            
            end
            
            jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).duration = 0;
            jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).tmod = 0;    
            jobs{2}.stats{1}.fmri_spec.sess(j).cond(k).mod = struct('name', {}, 'param', {}, 'poly', {});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % End condition loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        end

        %jobs{2}.stats{1}.fmri_spec.sess(j).multi_reg = editfilenames(char(f{j}(1,:)),'prefix','rp_agh','ext','.txt');
        jobs{2}.stats{1}.fmri_spec.sess(j).multi_reg = editfilenames(char(f{j}(1,:)),'prefix','rp_a','ext','.txt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % End session loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

	jobs{2}.stats{1}.fmri_spec.fact = struct('name',{},'levels', {});
    jobs{2}.stats{1}.fmri_spec.bases.hrf.derivs = [1 1];
    jobs{2}.stats{1}.fmri_spec.volt = 1;
    jobs{2}.stats{1}.fmri_spec.global = 'None';
    jobs{2}.stats{1}.fmri_spec.mask = {''};
    jobs{2}.stats{1}.fmri_spec.cvi = 'AR(1)';

    jobs{3}.stats{1}.fmri_est.spmmat = cellstr(fullfile(data_path5,subjects{i},data_path6,'SPM.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    save(fullfile(data_path5,subjects{i},data_path6,'first_level_model.mat'),'jobs');
    spm_jobman('run',jobs);

    clear jobs
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End subject loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purge jobs structure from memory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INFERENCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create list of desired contrasts - Output for Second Level Statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

contrasts = {...
    'Correct HRF',...
    'Correct Temporal',...
    'Correct Dispersion',...
    'Incorrect HRF',...
    'Incorrect Temporal',...
    'Incorrect Dispersion',...
    'Tool HRF',...
    'Tool Temporal',...
    'Tool Dispersion',...
    'Hand HRF',...
    'Hand Temporal',...
    'Hand Dispersion',...
    'All Correct'...
    'All Incorrect',...
    'All Tool',...
    'All Hand',...
    'Rest',...
    };

fcontrast = {'F-Test'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create vectors for t-contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create 12*n matrix for condition HRF, Temporal Derivative and Dispersion 
% Derivative contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tcont = zeros(17,19);
tcont(1:12,1:12) = kron(eye(12),[1]);
tcont(13:16,1:12) = kron(eye(4),[1 1 1]);
tcont(17,1:12) = -1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set to Loop Over Subjects 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1 : numel(subjects);

    clear jobs 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set to Loop Over Contrasts 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    for cont_nr = 1:numel(contrasts);
        
        contrasttype = contrasts{cont_nr};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        % Enter contasts here - loop through vectors for t-contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
        contr_input = tcont(cont_nr,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        % Set up job structure for contrasts (t-contrasts here)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(data_path5,subjects{i},data_path6,'SPM.mat'));
        jobs{1}.stats{1}.con.consess{1}.tcon.name = contrasttype;
        jobs{1}.stats{1}.con.consess{1}.tcon.convec = contr_input;
        jobs{1}.stats{1}.con.consess{1}.tcon.sessrep = 'repl';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        % Make sure NOT to overwrite existing contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        jobs{1}.stats{1}.con.delete = 0; 
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
        disp(['RUNNING ' contrasts{cont_nr} ' contrast specification for subject number  ' subjects{1,i}]);
        spm_jobman('run',jobs);
        
        disp(['"' contrasts{cont_nr} '"' ' t-contrast created for subject number  ' subjects{1,i}]);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % End Contrast Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
    
    end
    
    disp(['------------>>>       T-contrasts for Second Level Statistics created']);

    clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ALL vs Baseline - Output for Second Level Statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    tcont2 = [repmat([1 0 0],1,4) zeros(1,7)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    % Set up job structure for contrasts (t-contrasts here)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(data_path5,subjects{i},data_path6,'SPM.mat'));
    jobs{1}.stats{1}.con.consess{1}.tcon.name = 'All HRF vs Baseline';
    jobs{1}.stats{1}.con.consess{1}.tcon.convec = tcont2;
    jobs{1}.stats{1}.con.consess{1}.tcon.sessrep = 'repl';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    % Make sure NOT to overwrite existing contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    jobs{1}.stats{1}.con.delete = 0; 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    disp(['RUNNING ' contrasts{cont_nr} ' contrast specification for subject number  ' subjects{1,i}]);
    spm_jobman('run',jobs);

    disp(['"' contrasts{cont_nr} '"' ' All HRF vs Baseline contrast created for subject number  ' subjects{1,i}]);
    
    clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create vectors for f-contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fcont = [eye(3) eye(3) eye(3) eye(3) zeros(3,7)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    % Set up job structure for contrasts (f-contrasts here)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(data_path5,subjects{i},data_path6,'SPM.mat'));
    jobs{1}.stats{1}.con.consess{1}.fcon.name = char(fcontrast);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loop to index vector(s) for f-contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for k=1:size(fcont,1);
        jobs{1}.stats{1}.con.consess{1}.fcon.convec{1,k} = fcont(k,:);
    end

    jobs{1}.stats{1}.con.consess{1}.fcon.sessrep = 'repl';
    jobs{1}.stats{1}.con.delete = 0;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    disp(['RUNNING f-contrast specification for subject number  ' subjects{1,i}]);
    spm_jobman('run',jobs); 

    disp(['F-contasts created']);
    
    clear jobs
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Subject Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End Of File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
