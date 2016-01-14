function roisPlot

global bnbsystem

[FileName,PathName] = uigetfile([bnbsystem.results_edt.String '/rois_fig.mat'],'Save file name');

if FileName==0
    return
end

image = load([PathName FileName]);
image = image.aux;

[FileName,PathName] = uigetfile([bnbsystem.results_edt.String '/rois.mat'],'Save file name');
rois = load([PathName FileName]);
rois = rois.rois;

fh = figure;
imagesc(image+rois*500)

dcm = datacursormode(fh);
datacursormode on
%set(dcm, 'updatefcn',@myfunction)
set(dcm,'UpdateFcn',{@myfunction,rois});

function output_txt = myfunction(obj,event_obj,rois)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');
output_txt = {['ROI #: ' num2str(rois(pos(2),pos(1)))]};