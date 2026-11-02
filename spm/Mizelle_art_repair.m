function [] = Mizelle_art_repair(subjects);

spmv = spm('Ver'); spm_ver = 'spm2';
if (strcmp(spmv,'SPM5') | strcmp(spmv,'SPM8b') | strcmp(spmv,'SPM8') )
    spm_ver = 'spm5'; end



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
%sessions = {'Session 2'};


% PARAMETERS
spm_defaults;
OUTSLICEdef =  5;  %  Threshold above sample means to filter slices
   %  15 is very visible on contrast image. 8 is slightly visible.
% THREEE CONTROL OPTIONS
%   Mask the images    - Set amask = 1.
%   Median filter all the images  - Set allfilt = 1.
%   Detect and repair bad slices  - Set slicefilt = 1.

for iter1=1:numel(subjects);
    
    disp(['---------------------------->>>            ' ...;
    'Preprocessing subject ' subjects{iter1}]);

    for iter2=1:numel(sessions)
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
    

Pimages = spm_select('FPList', fullfile(data_path1,subjects{iter1},data_path2,sessions{iter2}), '^fmri.*\.img$');
  

%a = spm_select('FPList', fullfile(data_path1,subjects{i},data_path3), '^t1MPRAGE.*\.img$');
    

P = spm_vol(Pimages);

repair_flag = 4;



% repair_flag = spm_input('Which repair methods to use?', 1, 'm', ...
%     ' Repair Bad Slices and Write BadSliceLog ( repairs only the bad slices ) | Median Filter All Data  ( aggressive filter for very noisy data ) | Eliminate data outside head | Repair Bad Slices and Eliminate data outside head | Median Filter All Data and Eliminate data outside head',...
%               [1 2 3 4 5], 1);
if ( repair_flag == 3 ) amask = 1; allfilt = 0; slicefilt = 0; end
if ( repair_flag == 1 ) amask = 0; allfilt = 0; slicefilt = 1; end
if ( repair_flag == 2 ) amask = 0; allfilt = 1; slicefilt = 0; end
if ( repair_flag == 4 ) amask = 1; allfilt = 0; slicefilt = 1; end
if ( repair_flag == 5 ) amask = 1; allfilt = 1; slicefilt = 0; end

%  Set the prefix correctly on the written files
if  ( amask ==1 & allfilt == 0 & slicefilt == 0 ) prechar = 'h'; end
if  ( amask ==1 & allfilt == 1 & slicefilt == 0 ) prechar = 'fh'; end
if  ( amask ==1 & allfilt == 0 & slicefilt == 1 ) prechar = 'gh'; end
if  ( amask ==0 & allfilt == 1 & slicefilt == 0 ) prechar = 'f'; end
if  ( amask ==0 & allfilt == 0 & slicefilt == 1 ) prechar = 'g'; end

fprintf('\n NEW IMAGE FILES WILL BE CREATED');
fprintf('\n The filtered scan data will be saved in the same directory');
fprintf('\n with %s pre-pended to their filenames.\n',prechar);

if amask == 1 | slicefilt == 1 %  Automask options
%     mask_flag = spm_input('Which mask image to use?', 1, 'm', ...
%     'Automatic ( will generate ArtifactMask image ) | User specified mask ',...
%               [1 2], 1);
mask_flag = 1;
    if mask_flag == 2
         if strcmp(spm_ver,'spm5')
             maskimg = spm_select(1, '.img', 'Select mask image in functional space');
         else  % spm2 version
             maskimg = spm_get(1, '.img', 'Select mask image in functional space');
         end
         Automask = spm_read_vols(spm_vol(maskimg));
         maskcount = sum(sum(sum(Automask)));  %  Number of voxels in mask.
         voxelcount = prod(size(Automask));    %  Number of voxels in 3D volume.
    else  %  mask_flag == 1
        fprintf('\n Generated mask image is written to file ArtifactMask.img.\n');
        fprintf('\n');
        Pnames = P(1).fname;
        Automask = art_automask(Pnames(1,:),-1,1);
        maskcount = sum(sum(sum(Automask)));  %  Number of voxels in mask.
        voxelcount = prod(size(Automask));    %  Number of voxels in 3D volume.
    end
end

if amask == 1
    fprintf('\n ELIMINATE DATA OUTSIDE HEAD');
    fprintf('\n All scans will have voxels outside the head set to zero.\n');
end

if slicefilt == 1  % Prepare some thresholds for slice testing.
    fprintf('\n INTERPOLATE THROUGH BAD SLICES\n');
    % Find the slice orientation used to collect the data
    [ vx, vy, vz ] = size(Automask);
    orient = 0;
    if ( vx < vy & vx < vz ) orient = 1; disp(' Remove bad Sagittal slices'); end
    if ( vy < vx & vy < vz ) orient = 2; disp(' Remove bad Coronal slices'); end
    if ( vz < vx & vz < vy ) orient = 3; disp(' Remove bad Axial slices'); end
    nslice = min([vx vy vz]);
    if ( orient == 0 ) 
        disp('Cannot determine slice orientation for bad slice filtering.')
        return; 
    end
    % Find 3 samples of slice baseline activity outside the head.
    p = zeros(3,nslice);
    for i = 1:3
        Y1 = spm_read_vols(P(i));
        Y1 = ( 1 - Automask ).*Y1;
        % Get the plane sums perpendicular to orient direction
        if ( orient == 1 ) p(i,:) = mean(mean(Y1,3),2); end 
        if ( orient == 2 ) p(i,:) = mean(mean(Y1,1),3); end 
        if ( orient == 3 ) p(i,:) = mean(mean(Y1,1),2); end 
    end
    % Select a low value for each plane, and set threshold a bit above it.
    pq = 0.5*( min(p) + median(p,1));
    % Preview estimate of bad slice fraction...
       prebad = length(find(p(1,:) > pq + OUTSLICEdef));
       prebad = length(find(p(2,:) > pq + OUTSLICEdef)) + prebad;
       prebad = length(find(p(3,:) > pq + OUTSLICEdef)) + prebad;
       percentbad = round(prebad*100/(3*nslice));
       disp('Estimated percent bad slices at default threshold')
       disp(percentbad)
    % User Input Threshold, and default suggestion.
    %OUTSLICE = spm_input(['Select threshold (default is shown)' ],1,'n',OUTSLICEdef); 
    OUTSLICE = OUTSLICEdef;
    pq = pq + OUTSLICE;  % pq array is the threshold test for bad slices.
    fprintf('\n Interpolating new values for bad slices when ');
    fprintf('\n average value outside head is %3d counts over baseline.\n',OUTSLICE);
    fprintf('\n Bad slice log will be written.');
    fprintf('\n');
    %  DETECT, COUNT, AND LOG THE ARTIFACTS
    disp('Writing Artifact Log to location of image set')
    [ dirname, sname ] = fileparts(P(1).fname);   %  XXXXXX
    tstamp = clock;
    filen = ['BadSliceLog',date,'Time',num2str(tstamp(4)),num2str(tstamp(5)),'.txt'];
    logname = fullfile(dirname,filen);
    logID = fopen(logname,'wt');
    fprintf(logID,'Bad Slice Log, Image Set first file is:  \n  %s\n', sname);
    fprintf(logID,'Test Criteria for Artifacts');  
    fprintf(logID,'\n  Outslice (counts) = %4.1f' , OUTSLICE);
    fprintf(logID,'\n Slice Artifact List (Vol 1 = First File)\n');
	BadError = 0;     % Counts bad slices
end
     
if allfilt == 1
    fprintf('\n MEDIAN FILTER ALL THE DATA');
	fprintf('\n All scans are being filtered by median 3-point time filter.');
	fprintf('\n This is safe to do when TR = 2. Otherwise, use the');
	fprintf('\n    Remove Bad Slices option instead.\n');
    fprintf('\n');
end
spm_input('!DeleteInputObj');


%%
% Main Loop - Filter everything but the first and last volumes.
nscans = size(P,1);
Y4(1,:,:,:) = spm_read_vols(P(1));  % rows vary fastest
Y4(2,:,:,:) = spm_read_vols(P(2));
for i = 3:nscans
        Y4(3,:,:,:) = spm_read_vols(P(i));
        if allfilt == 1  % Filter all data by median.
            Yn = median(Y4,1);
            Yn2 = squeeze(Yn);
        end
        if slicefilt == 1  % Repair bad slices by linear interpolation.
            % Check if outside head value is over pq. If so, filter.
            Yn2 = squeeze(Y4(2,:,:,:));
            Y = ( 1 - Automask).*Yn2;
            if ( orient == 1 ) 
                py = mean(mean(Y,3),2); 
                for j = 1:vx
                    if py(j) > pq(j)  % slice needs to be filtered.
                        Yn2(j,:,:) = squeeze((Y4(1,j,:,:) + Y4(3,j,:,:))/2.0);
                        fprintf('   Fixed sagittal. Vol. %d, Slice %d.\n',i-1,j);
                        fprintf(logID,'   Fixed sagittal. Vol %d, Slice %d.\n',i-1,j);
                        BadError = BadError + 1; 
                    end  
                end 
            end
            if ( orient == 2 )
                py = mean(mean(Y,1),3); 
                for j = 1:vy
                    if py(j) > pq(j)  % slice needs to be filtered.
                        Yn2(:,j,:) = squeeze((Y4(1,:,j,:) + Y4(3,:,j,:))/2.0);
                        fprintf('   Fixed coronal. Vol %d, Slice %d.\n',i-1,j);
                        fprintf(logID,'   Fixed coronal. Vol %d, Slice %d.\n',i-1,j);
                        BadError = BadError + 1; 
                    end  
                end 
            end 
            if ( orient == 3 )
                py = mean(mean(Y,1),2);
                for j = 1:vz
                    if py(j) > pq(j)  % slice needs to be filtered.
                        Yn2(:,:,j) = squeeze((Y4(1,:,:,j) + Y4(3,:,:,j))/2.0);
                        fprintf('   Fixed axial. Vol %d, Slice %d.\n',i-1,j);
                        fprintf(logID,'   Fixed axial. Vol %d, Slice %d.\n',i-1,j);
                        BadError = BadError + 1; 
                    end  
                end 
            end    
        end
        if  ( allfilt == 0 & slicefilt == 0 )  % Head mask only.
            Yn2 = squeeze(Y4(2,:,:,:));
        end
        % Yn is a 4D file including the smoothed Y2 now.
        if ( amask ) Yn2 = Yn2.*Automask; end
        % Prepare the header for the filtered volume.
           V = spm_vol(P(i-1).fname);
           v = V;
           [dirname, sname, sext ] = fileparts(V.fname);
           sfname = [ prechar, sname ];
           filtname = fullfile(dirname,[sfname sext]);
           v.fname = filtname;
        %spm_write_vol(v,Yn2);  
        noscale_write_vol(v,Yn2);
        showprog = [' Corrected volume   ', sname, sext ];
        disp(showprog); 
        if i == 3   % Write unfiltered first scan
            Yn1 = squeeze(Y4(1,:,:,:)); 
            if ( amask ) Yn1 = Yn1.*Automask; end
            [dirname, sname, sext ] = fileparts(P(1).fname);
            sfname = [ prechar, sname ];
            filtname = fullfile(dirname,[sfname sext]);
            v.fname = filtname;
            %spm_write_vol(v,Yn1); 
            noscale_write_vol(v,Yn1);
            showprog = [' Corrected volume   ', sname, sext ];
            disp(showprog); 
        end
        if i == nscans  % Write unfiltered last scan.
            Yn1 = squeeze(Y4(3,:,:,:));
            if ( amask ) Yn1 = Yn1.*Automask; end
            Vlast = spm_vol(P(nscans).fname);
            [dirname, sname, sext ] = fileparts(P(nscans).fname);
            sfname = [ prechar, sname ];
            filtname = fullfile(dirname,[sfname sext]);
            v.fname = filtname;
            %spm_write_vol(v,Yn1); 
            noscale_write_vol(v,Yn1);
            showprog = [' Corrected volume   ', sname, sext ];
            disp(showprog); 
        end
        % Slide the read volumes window up.
        Y4(1,:,:,:) = Y4(2,:,:,:);
        Y4(2,:,:,:) = Y4(3,:,:,:); 
end

%  Summarize the slice errors, in the bad slice case.
if slicefilt == 1
    totalslices = nscans*nslice;
    ArtifactCount = BadError;  %  Number of unique bad slices with artifacts
    badpercent = BadError*100.0/totalslices;
    if ( ArtifactCount == 0 )
        disp(' CLEAN DATA! No bad slices detected'); 
        fprintf(logID, '\n\nCLEAN DATA. No bad slices detected.');
    end
    if  ArtifactCount > 0
        fprintf(logID,'\n\n Number of slices repaired = %4.0d',ArtifactCount);
        fprintf(logID,'\n\n Percentage of slices repaired = %5.1f',badpercent);
    end
    fclose(logID); 
end
    
disp('Done!')





    end
  
end

%---------------------------------------------------------------
% Create and write image without the scale and offset steps  
% This function is spm_write_vol without error checking and scaling.
function noscale_write_vol(V,Y);
V = spm_create_vol(V);
for p=1:V.dim(3),
    V = spm_write_plane(V,Y(:,:,p),p);
end;
%V = spm_close_vol(V);  % not for SPM5
