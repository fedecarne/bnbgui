function traces = bnbTP_extract

global bnbsystem

% Connect to BnB
ssh2_conn = ssh2_config(bnbsystem.sshdata.hostName,bnbsystem.sshdata.userName,bnbsystem.sshdata.password);

%% (1) ask for data folder
[~,folders] = ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && cd ' bnbsystem.code_folder ' && ls']);

[selection,ok] = listdlg('ListString',folders,'SelectionMode','single','Name','Select data folder');

if ~ok
    traces=[];
    return
end
datain_folder = [bnbsystem.bnbdatafolder '/' folders{selection,1}];

dataout_folder = 'data_out'; % folder to put temporary results
memory = '16'; % required memory for each job (Gb)

[~,msg] = ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && cd ' datain_folder ' && ls ']);

for i=1:size(msg,1)
    msg{i,1} = msg{i,1}(1:end-7); 
end

unique_pre = uniqueRowsCA(msg);

[selection,ok] = listdlg('ListString',unique_pre,'SelectionMode','single','Name','Select a prefix');
if ~ok
    return
end

im_pre = unique_pre{selection,1};
im_post = '.tif';

% Get number of images
[~,msg] = ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && cd ' datain_folder ' && ls ' im_pre '*' im_post]);
N = size(msg,1); % Number of images to register

disp([num2str(N) ' images in data folder...']);

%% (3) Extract fluorescence from ROI's

[rois_file,PathName] = uigetfile('*.mat','Select ROIs file',[bnbsystem.results_folder '/rois.mat']);

% send rois
disp('Uploading rois...')
ssh2_conn = scp_simple_put(bnbsystem.sshdata.hostName,bnbsystem.sshdata.userName,bnbsystem.sshdata.password,rois_file, bnbsystem.code_folder,PathName);


[~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && ./run_check_mat.sh /opt/hpc/pkg/MATLAB/R2013a "' rois_file '"']);
[~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && cat check_mat_result']);

trying=0;
while strcmp(msg,'1')
    
    trying = trying+1;
    if trying>5
        disp('Stopped trying...')
        return
    end
        
    disp('Uploading rois...')
    ssh2_conn = scp_simple_put(bnbsystem.sshdata.hostName,bnbsystem.sshdata.userName,bnbsystem.sshdata.password,'rois.mat', bnbsystem.code_folder,[PathName rois_file]);
    
    [~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && ./run_check_rois.sh /opt/hpc/pkg/MATLAB/R2013a "' rois_file '"']);
    [~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && cat check_rois_result']);

    
end

choice = questdlg('Do you want to upload a local reg_result or use the one currently in BnB?','Select reg_results',...
        'Upload a local registration file', 'Use the one in BnB','Upload a local registration file');
% Handle response
switch choice
    case 'Upload a local registration file'
        [reg_file,PathName] = uigetfile('*.mat','Select Registration file',[bnbsystem.results_folder '/reg_results.mat']);
        disp('Uploading registration file...')
        % send reg_results
        %sftpfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password,[PathName FileName], [code_folder '/reg_results.mat'])
        ssh2_conn = scp_simple_put(bnbsystem.sshdata.hostName,bnbsystem.sshdata.userName,bnbsystem.sshdata.password,reg_file, bnbsystem.code_folder,PathName);
        
        [~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && ./run_check_mat.sh /opt/hpc/pkg/MATLAB/R2013a "reg_results.mat"']);
        [~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && cat check_mat_result']);
        
        if strcmp(msg,'1')
            disp('Uploading failes. Try manually:')
            system(['scp ' PathName reg_file ' fcarneva@bnbdev2.cshl.edu:~/bnbTP'])
        end
        
    case 'Use the one in BnB'
        disp('Will use the reg_result currently in BnB.')
end

%if N<50
%    shortJob = '-l shortjob';
%else
    shortJob = '';
%end

%fTemplate = fopen('bnb_extractROI_template.sh');
%fOutput = fopen('bnb_extractROI.sh', 'w+');

fTemplate = fopen('bnb_extract_template.sh');
fOutput = fopen('bnb_extract.sh', 'w+');

tline = fgetl(fTemplate);
while ischar(tline)
    tline = strrep( tline, '<<<N>>>', num2str(N));
    tline = strrep( tline, '<<<datain>>>', datain_folder);
    tline = strrep( tline, '<<<memory>>>', memory);
    tline = strrep( tline, '<<<im_pre>>>', im_pre);
    tline = strrep( tline, '<<<im_post>>>', im_post);
    tline = strrep( tline, '<<<rois_file>>>', rois_file);
    tline = strrep( tline, '<<<reg_file>>>', reg_file);
    fprintf( fOutput, [tline '\n'] );
    tline = fgetl(fTemplate);
end
fclose(fTemplate);
fclose(fOutput);

disp( 'Uploading extractROI to blacknblue');

%ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder '&& rm -f bnb_extractROI.sh']);
ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder '&& rm -f bnb_extract.sh']);

% Send .sh to submit
%ssh2_conn = scp_simple_put(bnbsystem.sshdata.hostName,bnbsystem.sshdata.userName,bnbsystem.sshdata.password,'bnb_extractROI.sh', bnbsystem.code_folder);
ssh2_conn = scp_simple_put(bnbsystem.sshdata.hostName,bnbsystem.sshdata.userName,bnbsystem.sshdata.password,'bnb_extract.sh', bnbsystem.code_folder);


%[~, msg]  =  sshfrommatlabissue(channel,['cd ' bnbsystem.code_folder ' && if test -d roi; then echo "1"; fi']);
[~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && if test -d roi; then echo "1"; fi']);

if  ~isempty(msg{1,1})
    % There is already a folder roi in BnB
    choice = questdlg('There are extracted rois in BnB. Would you like to clean and run?', ...
        'Yes', 'No');
    % Handle response
    switch choice
        case 'Yes'
            [~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && rm -r roi']);
        case 'No'
            disp('Extraction cancelled.')
            return
    end
end

% Submit job array
%[~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && mkdir roi && qsub ' shortJob 'bnb_extractROI.sh']);
[~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && mkdir roi && qsub ' shortJob 'bnb_extract.sh']);
disp(msg)

%something went wrong here
%[~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder '&& rm -f bnb_extractROI.sh*']);
[~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder '&& rm -f bnb_extract.sh*']);

% Close connection to BnB
ssh2_close(ssh2_conn);

traces = consolidate(bnbsystem.sshdata, bnbsystem.code_folder, 'roi', bnbsystem.results_folder, 'traces',1);

disp('Done!')