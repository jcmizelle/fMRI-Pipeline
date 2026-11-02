cd '/path/to/data/';

clear all

pause(5.0)

clear all

%Mizelle_TOC_Batch_Modular([{'TOC015'}]);
Mizelle_TOC_Batch_Modular([{'TOC001' 'TOC002' 'TOC003' 'TOC004' 'TOC005' 'TOC006' 'TOC007' 'TOC008' 'TOC009' 'TOC010' 'TOC011' 'TOC012' 'TOC013' 'TOC014' 'TOC015'}]);
clear all

pause(5.0)

clear all

%Mizelle_TOC_Batch_First_Level([{'TOC014'}]);
Mizelle_TOC_Batch_First_Level([{'TOC001' 'TOC002' 'TOC003' 'TOC004' 'TOC005' 'TOC006'  'TOC007' 'TOC008' 'TOC009' 'TOC010' 'TOC011' 'TOC012' 'TOC013' 'TOC014' 'TOC015'}])
clear all

pause(5.0)

clear all

Mizelle_TOC_Batch_Second_Level([{'TOC001' 'TOC002' 'TOC003' 'TOC004' 'TOC005' 'TOC007' 'TOC008' 'TOC009' 'TOC010' 'TOC011' 'TOC012' 'TOC013' 'TOC014' 'TOC015'}]);

clear all

pause(5.0)

clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create mean structural image of ALL subjects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear jobs a

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loop over subjects to assign data to structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flist = {'spmF_0037'};% 'spmF_0038'};
fdir = ['/path/to/data/Second Level Statistics/Informed Basis Set'];
for i = 1:numel(flist)
    f{i} = spm_select('FPList', fdir, [flist{i} '\.img$']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Build jobs structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jobs{1}.util{1}.imcalc.input = f;
jobs{1}.util{1}.imcalc.output = fullfile(fdir,'Test cor-con.img');
%jobs{1}.util{1}.imcalc.expression = '(i2 > i1) & (i2 > 4)';
%jobs{1}.util{1}.imcalc.expression = '(i1 > i2) & (i1 > 4)';
%jobs{1}.util{1}.imcalc.expression = 'i2.*(i1>10)'; %'diff(X)'; %
jobs{1}.util{1}.imcalc.expression = 'i1 + 0./(i1>3)';
%jobs{1}.util{1}.imcalc.expression = 'i1 > 0.9'; %
jobs{1}.util{1}.imcalc.options.dmtx = 0;

% data_path4 = ['/DICOM/Data/'];
% save(fullfile(data_path1,'mean_image.mat'),'jobs');
 spm_jobman('run',jobs);   

 
V      = spm_vol(spm_select(1,'image','Select image...'));
[n, x] = histvol(V, 50);
	figure;
	bar(x,n);
 
 
% Make sure to first clear the graphics window

% Select images
Pbck = spm_select(1,'*.img','Select background image')
Psta = f{1};

% Set the threshold value
Th   = 4;  

% Create a new image where all voxels below Th have value NaN
PstaTh = [spm_str_manip(Psta,'s') 'Th'];
spm_imcalc_ui(Psta,PstaTh,'i1+(0./(i1>=Th))',{[],[],spm_type('float')},Th);

% Display!
spm_orthviews('image',Pbck,[0.05 0.05 0.9 0.9]);
spm_orthviews('addimage',1,PstaTh)

% Possibly, set the crosshairs to your favorite location
spm_orthviews('reposition',[0 -10 10])



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save and run module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% data_path4 = ['/DICOM/Data/'];
% save(fullfile(data_path1,'mean_image.mat'),'jobs');
 spm_jobman('run',jobs);   
% 
% disp(['---------------------------->>>       ' ...;
% 'Mean Image Complete'       <<<----------------------------']);

%% Determine FDR-Corrected 
FDRill('/path/to/data/Second Level Statistics/Informed Basis Set/spmT_0003.img',[],0.05,1)

[x y] = FDR_image('/path/to/data/Second Level Statistics/Informed Basis Set/spmF_0037.img',[],0.05);

[x y] = FDR_image('/path/to/data/snpmT+.img',133,0.05);


P = (['/path/to/data/Second Level Statistics/Informed Basis Set/spmT_0003.img'; '/path/to/data/Second Level Statistics/Informed Basis Set/spmT_0004.img']);
[t ts] = multFDR(P,[10000],0.05);


Mizelle_art_repair([{'TOC001'}]);

Mizelle_art_global([{'TOC013'}]);




subjects = ([{'TOC001' 'TOC002' 'TOC003' 'TOC004' 'TOC005' 'TOC006' 'TOC007' 'TOC008' 'TOC009' 'TOC010' 'TOC011' 'TOC012' 'TOC013' 'TOC014' 'TOC015'}]);


display_slices


%%
D = [];
for i = 1:numel(subjects);
    for j = 1:numel(sessions)
    %D = [];
        D = [D; spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^ghfmri.*\.img$')];
        D = [D; spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^ghfmri.*\.hdr$')];
        

 
    end
end

for xx = 1:numel(D);
     delete(char(D(xx,:)));
end


D = [];
for i = 1:numel(subjects);
    for j = 1:numel(sessions)
    %D = [];
        D = [D; spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^aghfmri.*\.img$')];
        D = [D; spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^aghfmri.*\.hdr$')];
        

 
    end
end

for xx = 1:numel(D);
     delete(char(D(xx,:)));
end



D = [];
for i = 1:numel(subjects);
    for j = 1:numel(sessions)
    %D = [];
        D = [D; spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^raghfmri.*\.img$')];
        D = [D; spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^raghfmri.*\.hdr$')];
        

 
    end
end

for xx = 1:numel(D);
     delete(char(D(xx,:)));
end

D = [];
for i = 1:numel(subjects);
    for j = 1:numel(sessions)
    %D = [];
        D = [D; spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^wraghfmri.*\.img$')];
        D = [D; spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^wraghfmri.*\.hdr$')];
        

 
    end
end

for xx = 1:numel(D);
     delete(char(D(xx,:)));
end

D = [];
for i = 1:numel(subjects);
    for j = 1:numel(sessions)
    %D = [];
        D = [D; spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^swraghfmri.*\.img$')];
        D = [D; spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^swraghfmri.*\.hdr$')];
        

 
    end
end

for xx = 1:numel(D);
     delete(char(D(xx,:)));
end


D = [];
for i = 1:numel(subjects);
    for j = 1:numel(sessions)
    %D = [];
        D = [D; spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^vswraghfmri.*\.img$')];
        D = [D; spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^vswraghfmri.*\.hdr$')];
        

 
    end
end

for xx = 1:numel(D);
     delete(char(D(xx,:)));
end


D = [];
for i = 1:numel(subjects);
    for j = 1:numel(sessions)
    %D = [];
        D = [D; spm_select('FPList', fullfile(data_path1,subjects{i},data_path2,sessions{j}), '^rp_aghfmri.*\.txt$')];
       
    end
end

for xx = 1:numel(D);
     delete(char(D(xx,:)));
end

