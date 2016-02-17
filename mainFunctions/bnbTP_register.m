function bnbTP_register

%{  
    (1) ask for data folder
    (2) ask for file names
    (3) clean previous parcial results
    (4) select registration method
    (4.1) if reference, ask for reference image
    (5) write .sh file and submit
    (6) consolidate
    (7) if recursive, register files
%}

global bnbsystem

% Connect to BnB
ssh2_conn = ssh2_config(bnbsystem.sshdata.hostName,bnbsystem.sshdata.userName,bnbsystem.sshdata.password);

%% (1) ask for data folder
[~,folders] = ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && cd data && ls']);

[selection,ok] = listdlg('ListString',folders,'SelectionMode','single','Name','Select data folder');

if ~ok
    return
end
datain_folder = ['data/' folders{selection,1}];

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
[~,msg] = ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && cd ' datain_folder ' && ls ' im_pre '*']);

N = size(msg,1); % Number of images to register

disp(['Analysing files: ' im_pre])
disp([num2str(N) ' images in data folder...']);


%% (3) clean previos parcial results
[~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && if test -d data_out; then echo "1"; fi']);

if ~isempty(msg{1,1})
    % There is already a folder in BnB
    choice = questdlg('There are registered files in BnB. Would you like to clean and run?', ...
        'Yes', 'No');
    % Handle response
    switch choice
        case 'Yes'
            [~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && rm -r data_out']);
        case 'No' | 'Cancel'
            disp('Registration cancelled.')
            return
    end
end


%% (4) select registration method
[choice,ok] = listdlg('PromptString','Select registration method:','SelectionMode','single','ListString',{'ReferenceImage','Recursive'});

if ~ok, disp('Registration cancelled.');return, end;
   
switch choice
    case 1
        %reg_method = 'run_si_register';
        reg_method = 'run_bnb_register';
                
        prompt = {'Reference image file:'};
        dlg_title = 'Enter image files';
        num_lines = 1;
        def = {'reg_med.tif'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        ref_image = answer{1,1};

    case 2
        reg_method = 'run_recursive_register';
end


%% (5) write .sh file and submit
this_folder = pwd;

if N<50
    shortJob = '-l shortjob';
else
    shortJob = '';
end

chan = 1;

% Fill template to run jobs
fTemplate = fopen('bnb_register_template.sh');
fOutput = fopen('bnb_register.sh', 'w+');

tline = fgetl(fTemplate);
while ischar(tline)
    tline = strrep( tline, '<<<reg_method>>>', reg_method);
    tline = strrep( tline, '<<<N>>>', ['"' num2str(N) '"']);
    tline = strrep( tline, '<<<datain>>>', ['"' datain_folder '"']);
    tline = strrep( tline, '<<<dataout>>>', ['"' dataout_folder '/out$SGE_TASK_ID"']);
    tline = strrep( tline, '<<<memory>>>', ['"' memory '"']);
    
    %if strcmp(reg_method,'run_si_register')
    if strcmp(reg_method,'run_bnb_register')
        tline = strrep( tline, '<<<ref_image>>>', ['"' datain_folder '/' ref_image '"']);
    end
    
    if strcmp(reg_method,'run_recursive_register')
        tline = strrep( tline, '<<<ref_image>>>', '');
    end
    
    tline = strrep( tline, '<<<chan>>>', ['"' num2str(chan) '"']);
    tline = strrep( tline, '<<<im_pre>>>', ['"' im_pre '"']);
    tline = strrep( tline, '<<<im_post>>>', ['"' im_post '"']);
    fprintf( fOutput, [tline '\n'] );
    tline = fgetl(fTemplate);
end
fclose(fTemplate);
fclose(fOutput);

disp( 'Uploading registration code to blacknblue...');

% Send .sh to submit
ssh2_conn = scp_simple_put(bnbsystem.sshdata.hostName,bnbsystem.sshdata.userName,bnbsystem.sshdata.password,'bnb_register.sh', bnbsystem.code_folder);

% Submit job array

[~, msg]  =  ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder ' && mkdir ' dataout_folder ' && qsub ' shortJob ' bnb_register.sh']);
disp(msg)

% Delete .o and .e files
ssh2_command(ssh2_conn,['cd ' bnbsystem.code_folder '&& rm -f bnb_register.sh*']);

% Close connection to BnB
ssh2_close(ssh2_conn);

results = consolidate(bnbsystem.sshdata, bnbsystem.code_folder, dataout_folder, bnbsystem.results_folder, 'reg_results',1);

%% (6) if recursive, register between files
for chan=1:4 % channels
    
    r_channel{1,chan} =  cell2mat(results(:,chan));
    
    if ~isempty(r_channel{1,chan})
        if strcmp(reg_method,'run_recursive_register')
            %Register between files
            means = reshape([r_channel{1,chan}(:,1).frameMean],size(r_channel{1,chan}(1,1).frameMean,1),size(r_channel{1,chan}(1,1).frameMean,2),size(r_channel{1,chan},1));
            r = sbxalign_files(means,1:size(r_channel{1,chan},1));
            for i=1:size(r_channel{1,chan},1)
                r_channel{1,chan}(i,1).frameRegister = r_channel{1,chan}(i,1).frameRegister + ones(size(r_channel{1,chan}(i,1).frameRegister,1),1)*r.T(i,:);
                r_channel{1,chan}(i,1).frameMean = circshift(r_channel{1,chan}(i,1).frameMean,r.T(i,:));
            end
            
        end
    end
end
results=r_channel;
disp('Done!')
save([bnbsystem.results_folder '/' im_pre 'reg'],'results');
if exist('reg_results.mat', 'file')==2
  delete('reg_results.mat');
end
