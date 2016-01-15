function r_consolidated = consolidate(sshdata, code_folder, datafolder, results_folder, fileout, continuous_inspection)
%CONSOLIDATE Summary of this function goes here
%   Detailed explanation goes here

userName = sshdata.userName;
hostName = sshdata.hostName;
password = sshdata.password;

% Fill template to consolidate results
fTemplate = fopen('bnb_consolidate_template.sh');
fOutput = fopen('bnb_consolidate.sh', 'w+');

tline = fgetl(fTemplate);
while ischar(tline)
    tline = strrep( tline, '<<<datafolder>>>', datafolder);
    tline = strrep( tline, '<<<fileout>>>', fileout);
    fprintf( fOutput, [tline '\n'] );
    tline = fgetl(fTemplate);
end
fclose(fTemplate);
fclose(fOutput);

% Connect to BnB
ssh2_conn = ssh2_config(hostName,userName,password);

done = 0;
while done == 0

    [~, msg]  =  ssh2_command(ssh2_conn,'qstat');
    
    if isempty(msg{1,1})
 
        disp( 'Consolidating...');
        
        % Send .sh to consolidate
        ssh2_conn = scp_simple_put(hostName,userName,password,'bnb_consolidate.sh', code_folder);
        
        % Submit consolidation job
        [~, msg]  =  ssh2_command(ssh2_conn,['cd ' code_folder ' && qsub bnb_consolidate.sh']);
        
        % Wait and bring the results
        while ~isempty(msg{1,1})
            % Bring the results
            [~, msg]  =  ssh2_command(ssh2_conn,'qstat');
        end
        % Remove consolidate sh, e and o files
        ssh2_command(ssh2_conn,['cd ' code_folder '&& rm -f bnb_consolidate.sh*']);
        
        % Close connection to BnB
        ssh2_conn = ssh2_close(ssh2_conn);
        
        % Ready to retrieve results from BnB?
        choice = questdlg('Ready to retrieve results from BnB?', 'Yes', 'No');
        % Handle response
        switch choice
            case 'No'
                r_consolidated = 0;
                return
        end
%        system(['scp fcarneva@bnbdev1.cshl.edu:~/' code_folder '/' fileout '.mat ' results_folder '/' fileout '.mat']);
        scp_simple_get(hostName,userName,password,[code_folder '/' fileout '.mat '],results_folder);
        
        r = load([results_folder '/' fileout '.mat']);
        r = cell2mat(r.results);
        r = [r.results]';
        
        aux = cell2mat(r(:,1));
        index = [aux.index]';
        %reorder according to file index
        [~,sorted_idx] = sort(index);
        
        r_consolidated = r(sorted_idx,:);
        done=1;
        
    else
        disp(msg);
        if ~continuous_inspection
            done=1;
        end
    end
end