function Mizelle_TOC_Batch_Second_Level(subjects);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% J.C. Mizelle
% 12/30/2009
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script should be executed following the preprocessing steps as 
% outlined in Mizelle_TOC_Batch_First_Level.m. This script performs second
% -level analysis scross all subjects and conditions. Output from the
% previous script (Mizelle_TOC_Batch_First_Level.m) is automatically called
% and used to evaluate fMRI activation at the group level. Output of this
% module is sent to a folder in the Experiment (Parent) folder called 
% Second Level Statistics. Subfolders are created for Canonical and for
% Informed Basis Set statistics.
%
%   Experiment
%       |
%       |_____ Second Level Statistics
%       |
%       |_____ Canonical
%       |_____ Informed Basis Set
%       |
%       |_____ Subject 1
%       |_________ Stats Output
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
% This script also calls editfilenames.m 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAUSE, depending on computational speed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pause(2.0)

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
data_path2 = ['/DICOM/Stats/Categorical/'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Identify Folders for Individual Experimental Runs (Sessions Folders)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%subjects = {'TOC002' 'TOC003' 'TOC004' 'TOC006'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Identify Condition Names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

condnames = {'Correct' 'Context' 'Tool' 'Hand'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define Paths for Stats Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_path3 = ['/path/to/data/Second Level Statistics/Canonical'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Output Directory if Needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if (exist(data_path3) == 0);
       mkdir (data_path3);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set to Loop Over Conditions for File Concatenation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Based on structured output (contrast numbers) from first-level batch: 
% con.*1.img, con.*2.img, con.*3.img and con.*4.img are contrast images 
% with only loading of the canonical HRF response
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cnumbers = {'0001' '0002' '0003' '0004'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify informed basis set for creating cells.
% To be used below for creating a loop.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

canonical = {...
    'Correct',...
    'Incorrect',...
    'Tool',...
    'Hand'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialise SPM Defaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spm('Defaults','fMRI');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MODEL SPECIFICATION AND ESTIMATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize jobs structure and set general configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jobs{1}.util{1}.md.basedir = cellstr(data_path1);
jobs{1}.util{1}.md.name = 'Canonical';

jobs{2}.stats{1}.factorial_design.dir = cellstr(data_path3);

jobs{2}.stats{1}.factorial_design.dir = cellstr(data_path3);
jobs{2}.stats{1}.factorial_design.des.fd.fact.name = 'Condition';
jobs{2}.stats{1}.factorial_design.des.fd.fact.levels = 4;
jobs{2}.stats{1}.factorial_design.des.fd.fact.dept = 1;
jobs{2}.stats{1}.factorial_design.des.fd.fact.variance = 1; 
jobs{2}.stats{1}.factorial_design.des.fd.fact.gmsca = 0;
jobs{2}.stats{1}.factorial_design.des.fd.fact.ancova = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over the informed baisis set to specify levels and cells
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:numel(canonical);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loop over subjects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    for ii = 1:numel(subjects);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Concatenate List of Files for HRF, Temporal and Dispersion Derivatives
%   Per Conditon
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    f{ii,:} = spm_select('FPList', fullfile(data_path1,subjects{ii},data_path2), char(strcat('^con.*', cnumbers(i), '\.img$')));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % End Subject Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    end
    
    jobs{2}.stats{1}.factorial_design.des.fd.icell(i).levels = i;
    jobs{2}.stats{1}.factorial_design.des.fd.icell(i).scans = editfilenames(cellstr(f),'ext','.img,1');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Loop Over Basis Set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

% jobs{2}.stats{1}.factorial_design.cov.c = {}; 
% jobs{2}.stats{1}.factorial_design.cov.cname = {};
% jobs{2}.stats{1}.factorial_design.cov.iCFI = {};
% jobs{2}.stats{1}.factorial_design.cov.iCC = {};
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Complete Jobs Structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jobs{2}.stats{1}.factorial_design.masking.tm.tm_none = 1;
jobs{2}.stats{1}.factorial_design.masking.im = 1;
jobs{2}.stats{1}.factorial_design.masking.em = {''};
jobs{2}.stats{1}.factorial_design.globalc.g_omit = 1;
jobs{2}.stats{1}.factorial_design.globalm.gmsca.gmsca_no = 1;
jobs{2}.stats{1}.factorial_design.globalm.glonorm = 1;

jobs{3}.stats{1}.fmri_est.spmmat = cellstr(fullfile(data_path3,'SPM.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save(fullfile(data_path3,'second_level_model.mat'),'jobs');
spm_jobman('run',jobs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purge jobs structure from memory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create List of Desired Contrasts for Second Level Statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

contrasts = {...
    'Correct vs Baseline',...
    'Incorrect vs Baseline',...
    'Tool vs Baseline',...
    'Hand vs Baseline',...
    'All vs Baseline'...,
    'Baseline_vs_All',...
    'Experimental vs Control',...
    'Correct vs Incorrect',...
    'Incorrect vs Correct',...
    'Correct vs Tool',...
    'Tool vs Correct',...
    'Correct vs Hand',...
    'Hand vs Correct',...
    'Incorrect vs Tool',...
    'Tool vs Incorrect',...
    'Incorrect vs Hand',...
    'Hand vs Incorrect',...
    'Tool vs Hand',...
    'Hand vs Tool',...
    };

tcont = [1 0 0 0];
tcont = [tcont;0 1 0 0];
tcont = [tcont;0 0 1 0];
tcont = [tcont;0 0 0 1];
tcont = [tcont;1 1 1 1];
tcont = [tcont;-1 -1 -1 -1];
tcont = [tcont;1 1 -1 -1];
tcont = [tcont;1 -1 0 0];
tcont = [tcont;-1 1 0 0];
tcont = [tcont;1 0 -1 0];
tcont = [tcont;-1 0 1 0];
tcont = [tcont;1 0 0 -1];
tcont = [tcont;-1 0 0 1];
tcont = [tcont;0 1 -1 0];
tcont = [tcont;0 -1 1 0];
tcont = [tcont;0 1 0 -1];
tcont = [tcont;0 -1 0 1];
tcont = [tcont;0 0 1 -1];
tcont = [tcont;0 0 -1 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start building jobs structure for contrast manager
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(data_path3,'SPM.mat'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k = 1:numel(contrasts); 
    

    jobs{1}.stats{1}.con.consess{k}.tcon.name = char(contrasts{k});

    jobs{1}.stats{1}.con.consess{k}.tcon.convec = tcont(k,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End loop over contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save(fullfile(data_path3,'second_level_contrasts.mat'),'jobs');
spm_jobman('run',jobs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purge jobs structure from memory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If desired, create new contrasts which are corrected for familywise error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% for k = 1:numel(contrasts);
%     
%     jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(data_path3,'SPM.mat'));
%     jobs{1}.stats{1}.results.conspec(k).contrasts = Inf;
%     jobs{1}.stats{1}.results.conspec(k).threshdesc = 'FWE';
%     
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Save and run module
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% 
% save(fullfile(data_path3,'correct_stats.mat'),'jobs');
% spm_jobman('run',jobs);
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%                  BEGIN INFORMED BASIS SET
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Purge Matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear tcont fcont contrasts jobs 
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
data_path2 = ['/DICOM/Stats/Categorical/Second Level Contrasts/'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Identify Folders for Individual Experimental Runs (Sessions Folders)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%subjects = {'TOC002' 'TOC003' 'TOC004'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Identify Condition Names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

condnames = {'Correct' 'Context' 'Tool' 'Hand'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define Paths for Stats Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_path3 = ['/path/to/data/Second Level Statistics/Informed Basis Set'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Output Directory if Needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if (exist(data_path3) == 0);
       mkdir (data_path3);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set to Loop Over Conditions for File Concatenation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Based on structured output (contrast numbers) from first-level batch: 
% con.*1.img - con.*3.img are HRF, Temporal and Dispersion Derivatives 
% for Condition 1, con.*4.img - con.*6.img are HRF, Temporal and 
% Dispersion Derivatives for Condition 2, etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cnumbers = {'0001' '0002' '0003' '0004' '0005' '0006' '0007' '0008' '0009' '0010' '0011' '0012' '0013' '0014' '0015' '0016'};
%cnumbers = subjects;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify informed basis set for creating cells.
% To be used below for creating a loop.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

basis_set = {...
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
    };


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialise SPM Defaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spm('Defaults','fMRI');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MODEL SPECIFICATION AND ESTIMATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize jobs structure and set general configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jobs{1}.util{1}.md.basedir = cellstr(data_path1);
jobs{1}.util{1}.md.name = 'Informed Basis Set';

jobs{2}.stats{1}.factorial_design.dir = cellstr(data_path3);

jobs{2}.stats{1}.factorial_design.dir = cellstr(data_path3);
jobs{2}.stats{1}.factorial_design.des.fd.fact.name = 'Condition';
jobs{2}.stats{1}.factorial_design.des.fd.fact.levels = 12;
jobs{2}.stats{1}.factorial_design.des.fd.fact.dept = 1;
jobs{2}.stats{1}.factorial_design.des.fd.fact.variance = 1; 
jobs{2}.stats{1}.factorial_design.des.fd.fact.gmsca = 0;
jobs{2}.stats{1}.factorial_design.des.fd.fact.ancova = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over the informed baisis set to specify levels and cells
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:numel(basis_set);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loop over subjects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    for ii = 1:numel(subjects);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Concatenate List of Files for HRF, Temporal and Dispersion Derivatives
%   Per Conditon
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    f{ii,:} = spm_select('FPList', fullfile(data_path1,subjects{ii},data_path2), char(strcat('^con.*', cnumbers(i), '\.img$')));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % End Subject Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    end
    
    jobs{2}.stats{1}.factorial_design.des.fd.icell(i).levels = i;
    jobs{2}.stats{1}.factorial_design.des.fd.icell(i).scans = editfilenames(cellstr(f),'ext','.img,1');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Loop Over Basis Set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

% jobs{2}.stats{1}.factorial_design.cov.c = {}; 
% jobs{2}.stats{1}.factorial_design.cov.cname = {};
% jobs{2}.stats{1}.factorial_design.cov.iCFI = {};
% jobs{2}.stats{1}.factorial_design.cov.iCC = {};
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Complete Jobs Structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jobs{2}.stats{1}.factorial_design.masking.tm.tm_none = 1;
jobs{2}.stats{1}.factorial_design.masking.im = 1;
jobs{2}.stats{1}.factorial_design.masking.em = {''};
jobs{2}.stats{1}.factorial_design.globalc.g_omit = 1;
jobs{2}.stats{1}.factorial_design.globalm.gmsca.gmsca_no = 1;
jobs{2}.stats{1}.factorial_design.globalm.glonorm = 1;

jobs{3}.stats{1}.fmri_est.spmmat = cellstr(fullfile(data_path3,'SPM.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save(fullfile(data_path3,'second_level_model.mat'),'jobs');
spm_jobman('run',jobs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purge jobs structure from memory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create List of Desired T-Contrasts for Second Level Statistics for
%% Canonical HRF Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tcontrasts = {...
    'Canonical Correct',...
    'Canonical Incorrect',...
    'Canonical Tool',...
    'Canonical Hand',...
    'Canonical All',...
    'Canonical Experimental vs Control',...
    'Canonical Correct vs Incorrect',...
    'Canonical Incorrect vs Correct',...
    'Canonical Correct vs Tool',...
    'Canonical Tool vs Correct',...
    'Canonical Correct vs Hand',...
    'Canonical Hand vs Correct',...
    'Canonical Incorrect vs Tool',...
    'Canonical Tool vs Incorrect',...
    'Canonical Incorrect vs Hand',...
    'Canonical Hand vs Incorrect',...
    'Canonical Tool vs Hand',...
    'Canonical Hand vs Tool',...
    'Basis Set Correct',...
    'Basis Set Incorrect',...
    'Basis Set Tool',...
    'Basis Set Hand',...
    'Rest',...
    };

tcont = [1 zeros(1,11)];
tcont = [tcont; zeros(1,3) 1 zeros(1,8)];
tcont = [tcont; zeros(1,6) 1 zeros(1,5)];
tcont = [tcont; zeros(1,9) 1 zeros(1,2)];
tcont = [tcont; 1 zeros(1,2) 1 zeros(1,2) 1 zeros(1,2) 1 zeros(1,2)];
tcont = [tcont; 1 zeros(1,2) 1 zeros(1,2) -1 zeros(1,2) -1 zeros(1,2)];
tcont = [tcont; 1 zeros(1,2) -1 zeros(1,8)];
tcont = [tcont; -1 zeros(1,2) 1 zeros(1,8)];
tcont = [tcont; 1 zeros(1,2) -1 zeros(1,8)];
tcont = [tcont; -1 zeros(1,2) 1 zeros(1,8)];
tcont = [tcont; 1 zeros(1,8) -1  zeros(1,2)];
tcont = [tcont; -1 zeros(1,8) 1  zeros(1,2)];
tcont = [tcont; zeros(1,3) 1 zeros(1,2) -1 zeros(1,5)];
tcont = [tcont; zeros(1,3) -1 zeros(1,2) 1 zeros(1,5)];
tcont = [tcont; zeros(1,3) 1 zeros(1,5) -1 zeros(1,2)];
tcont = [tcont; zeros(1,3) -1 zeros(1,5) 1 zeros(1,2)];
tcont = [tcont; zeros(1,6) 1 zeros(1,2) -1 zeros(1,2)];
tcont = [tcont; zeros(1,6) -1 zeros(1,2) 1 zeros(1,2)];
tcont = [tcont;kron(eye(4),[1 1 1])];
tcont = [tcont;ones(1,12)*-1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start building jobs structure for contrast manager
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(data_path3,'SPM.mat'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k = 1:numel(tcontrasts); 
    

    jobs{1}.stats{1}.con.consess{k}.tcon.name = char(tcontrasts{k});

    jobs{1}.stats{1}.con.consess{k}.tcon.convec = tcont(k,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End loop over contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

save(fullfile(data_path3,'second_level_tcontrasts.mat'),'jobs');
spm_jobman('run',jobs);

clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create List of Desired F-Contrasts for Second Level Statistics to
%% Incorporate Basis Set Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fcontrasts = {...
    'Correct vs Baseline',...
    'Incorrect vs Baseline',...
    'Tool vs Baseline',...
    'Hand vs Baseline',...
    'All vs Baseline'...,
    'Experimental vs Control',...
    'Control vs Experimental',...
    'Correct vs Incorrect',...
    'Incorrect vs Correct',...
    'Correct vs Tool',...
    'Tool vs Correct',...
    'Correct vs Hand',...
    'Hand vs Correct',...
    'Incorrect vs Tool',...
    'Tool vs Incorrect',...
    'Incorrect vs Hand',...
    'Hand vs Incorrect',...
    'Tool vs Hand',...
    'Hand vs Tool',...
    };

fcont = [eye(3) zeros(3,9)];
fcont = [fcont; zeros(3,3) eye(3) zeros(3,6)];
fcont = [fcont; zeros(3,6) eye(3) zeros(3,3)];
fcont = [fcont; zeros(3,9) eye(3)];
fcont = [fcont; eye(3) eye(3) eye(3) eye(3)];
fcont = [fcont; eye(3) eye(3) -1*eye(3) -1*eye(3)];
fcont = [fcont; -1*eye(3) -1*eye(3) eye(3) eye(3)];
fcont = [fcont; eye(3) -1*eye(3) zeros(3,6)];
fcont = [fcont; -1*eye(3) eye(3) zeros(3,6)];
fcont = [fcont; eye(3) zeros(3,3) -1*eye(3) zeros(3,3)];
fcont = [fcont; -1*eye(3) zeros(3,3) eye(3) zeros(3,3)];
fcont = [fcont; eye(3) zeros(3,6) -1*eye(3)];
fcont = [fcont; -1*eye(3) zeros(3,6) eye(3)];
fcont = [fcont; zeros(3,3) eye(3) -1*eye(3) zeros(3,3)];
fcont = [fcont; zeros(3,3) -1*eye(3) eye(3) zeros(3,3)];
fcont = [fcont; zeros(3,3) eye(3) zeros(3,3) -1*eye(3)];
fcont = [fcont; zeros(3,3) -1*eye(3) zeros(3,3) eye(3)];
fcont = [fcont; zeros(3,6) eye(3) -1*eye(3)];
fcont = [fcont; zeros(3,6) -1*eye(3) eye(3)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start building jobs structure for contrast manager
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(data_path3,'SPM.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Because loop will iterate in steps of three, create counter for number of
% contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iterate by three to account for 3 parameters (HRF and Temporal and 
% Dispersion Derivatives) per contrast in the contrast matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k = 1:3:numel(fcontrasts)*3; 
    

    jobs{1}.stats{1}.con.consess{i}.fcon.name = char(fcontrasts{i});

     jobs{1}.stats{1}.con.consess{i}.fcon.convec{i,1} = fcont(k,:);
     jobs{1}.stats{1}.con.consess{i}.fcon.convec{i,2} = fcont(k+1,:);
     jobs{1}.stats{1}.con.consess{i}.fcon.convec{i,3} = fcont(k+2,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update counter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    i = i+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End loop over contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save(fullfile(data_path3,'second_level_fcontrasts.mat'),'jobs');
spm_jobman('run',jobs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purge jobs structure from memory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If desired, create new contrasts which are corrected for familywise error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% for k = 1:numel(contrasts);
%     
%     jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(data_path3,'SPM.mat'));
%     jobs{1}.stats{1}.results.conspec(k).contrasts = Inf;
%     jobs{1}.stats{1}.results.conspec(k).threshdesc = 'FWE';
%     
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Save and run module
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% save(fullfile(data_path3,'correct_stats.mat'),'jobs');
% spm_jobman('run',jobs);