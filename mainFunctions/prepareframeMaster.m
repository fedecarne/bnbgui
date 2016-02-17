function frameMaster = prepareframeMaster(filename)

r_all = load(filename);
r_all = r_all.results;


    
for channel=1:4
    r = r_all(:,channel);
    reg_r = cell2mat(r);
   

    if ~isempty(reg_r)
        
        frameMaster.frameMeanMaster{1,channel} = reshape([reg_r.frameMean],size(reg_r(1,1).frameMean,1),size(reg_r(1,1).frameMean,2),size(reg_r,1));
        frameMaster.frameVarMaster{1,channel} = var(frameMaster.frameMeanMaster{1,channel},1,3);
        frameMaster.frameCorrMaster{1,channel} = reshape([reg_r.ccimage],size(reg_r(1,1).ccimage,1),size(reg_r(1,1).ccimage,2),size(reg_r,1));
    else
        frameMaster.frameMeanMaster{1,channel} = [];
        frameMaster.frameVarMaster{1,channel} = [];
        frameMaster.frameCorrMaster{1,channel} = [];
    end
end

end

%{
function frameMaster = prepareframeMaster(filename)

r_all = load(filename);
r_all = r_all.results;

%frameMaster = struct('frameMeanMaster',cell(1,4),'frameVarMaster',cell(1,4),'frameCorrMaster',cell(1,4));

for channel=1:4

    for file=1:size(r_all,1)

        r = r_all{file,1}.results;
    
        if ~isempty(r{channel,1})

            frameMaster.frameMeanMaster{1,channel}(:,:,file) = r{channel,1}.frameMean;
            frameMaster.frameCorrMaster{1,channel}(:,:,file) = r{channel,1}.ccimage;

        else
            
            frameMaster.frameMeanMaster{1,channel} = [];
            frameMaster.frameCorrMaster{1,channel} = [];
        end
    
    end
    
    frameMaster.frameVarMaster{1,channel}(:,:,1) = var(frameMaster.frameMeanMaster{1,channel},1);

end
%}