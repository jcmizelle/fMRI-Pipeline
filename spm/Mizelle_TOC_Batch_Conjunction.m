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

data_path3 = ['/path/to/data/Second Level Statistics/Canonical/Conjunction'];

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

cnumbers = {'0009' '0011' '0013' '0015'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify informed basis set for creating cells.
% To be used below for creating a loop.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

canonical = {...
    'Correct vs Tool',...
    'Correct vs Hand',...
    'Incorrect vs Tool',...
    'Incorrect vs Hand'};

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

% jobs{1}.util{1}.md.basedir = cellstr(data_path1);
% jobs{1}.util{1}.md.name = 'Canonical';
% 
% jobs{2}.stats{1}.factorial_design.dir = cellstr(data_path3);
% 
% for ii = 1:numel(subjects);
%     
%     f{ii,:} = spm_select('FPList', fullfile(data_path1,subjects{ii},data_path2), char(strcat('^con.*', cnumbers(1), '\.img$')));
%     
% end
% 
% jobs{2}.stats{1}.factorial_design.des.t2.scans1 = f;
% 
% for ii = 1:numel(subjects);
%     
%     f{ii,:} = spm_select('FPList', fullfile(data_path1,subjects{ii},data_path2), char(strcat('^con.*', cnumbers(3), '\.img$')));
%     
% end
% 
% jobs{2}.stats{1}.factorial_design.des.t2.scans2 = f;
% 
% 
% jobs{2}.stats{1}.factorial_design.des.t2.dept = 0; 
% jobs{2}.stats{1}.factorial_design.des.t2.variance = 1; 
% jobs{2}.stats{1}.factorial_design.des.t2.gmsca = 0;
% jobs{2}.stats{1}.factorial_design.des.t2.ancova = 0;


jobs{1}.util{1}.md.basedir = cellstr(data_path1);
jobs{1}.util{1}.md.name = 'Canonical';

jobs{2}.stats{1}.factorial_design.dir = cellstr(data_path3);

for ii = 1:numel(subjects);
    
    f{ii,:} = spm_select('FPList', fullfile(data_path1,subjects{ii},data_path2), char(strcat('^con.*', cnumbers(1), '\.img$')));
    
end

jobs{2}.stats{1}.factorial_design.des.t1.scans1 = f;


jobs{2}.stats{1}.factorial_design.des.t1.dept = 0; 
jobs{2}.stats{1}.factorial_design.des.t1.variance = 1; 
jobs{2}.stats{1}.factorial_design.des.t1.gmsca = 0;
jobs{2}.stats{1}.factorial_design.des.t1.ancova = 0;


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

save(fullfile(data_path3,'second_level_conjunction.mat'),'jobs');
spm_jobman('run',jobs);

jobs{1}.util{1}.md.basedir = cellstr(data_path1);
jobs{1}.util{1}.md.name = 'Canonical';

jobs{2}.stats{1}.factorial_design.dir = cellstr(data_path3);

for ii = 1:numel(subjects);
    
    f{ii,:} = spm_select('FPList', fullfile(data_path1,subjects{ii},data_path2), char(strcat('^con.*', cnumbers(3), '\.img$')));
    
end

jobs{2}.stats{1}.factorial_design.des.t1.scans1 = f;


jobs{2}.stats{1}.factorial_design.des.t1.dept = 0; 
jobs{2}.stats{1}.factorial_design.des.t1.variance = 1; 
jobs{2}.stats{1}.factorial_design.des.t1.gmsca = 0;
jobs{2}.stats{1}.factorial_design.des.t1.ancova = 0;


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

save(fullfile(data_path3,'second_level_conjunction.mat'),'jobs');
spm_jobman('run',jobs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purge jobs structure from memory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create List of Desired Contrasts for Second Level Statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

contrasts = {...
    'Correct - Tool vs Incorrect - Tool',...
    'Correct - Hand vs Incorrect - Hand',...
    };

tcont = [1 0];
tcont = [tcont;0 1];

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

save(fullfile(data_path3,'second_level_conjunction.mat'),'jobs');
spm_jobman('run',jobs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purge jobs structure from memory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear jobs