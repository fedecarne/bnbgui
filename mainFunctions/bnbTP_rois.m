function bnbTP_rois

global bnbsystem

[FileName,PathName,FilterIndex] = uigetfile('*.mat','Select registration file',[bnbsystem.results_edt.String '/reg_results.mat']);
if FileName==0
    return
end

frameMaster = prepareframeMaster([PathName FileName]);
make_rois_edge(frameMaster);