function bnbgui

close all
clear
clc

global bnbsystem

btn_h = 120;
btn_v = 30;

bnbsystem.mainFig = figure('Visible','on','MenuBar','none','Position',[400 250 1000 500],'Name','bnb Main','NumberTitle','off');

bnbsystem.uimenu = uimenu('Label','Workspace');
uimenu(bnbsystem.uimenu,'Label','Register','Callback',@register_Callback);
uimenu(bnbsystem.uimenu,'Label','Draw rois','Callback',@rois_Callback);
uimenu(bnbsystem.uimenu,'Label','Extract rois','Callback',@rextract_Callback);
uimenu(bnbsystem.uimenu,'Label','Clean','Callback',@clean_Callback);
uimenu(bnbsystem.uimenu,'Label','Plot Rois','Callback',@roisplot_Callback);
uimenu(bnbsystem.uimenu,'Label','Set results folder','Callback',@resultfolder_Callback,'Separator','on','Accelerator','R');
uimenu(bnbsystem.uimenu,'Label','Set credentials','Callback',@credentials_Callback);
uimenu(bnbsystem.uimenu,'Label','Save','Callback',@save_Callback,'Separator','on');
uimenu(bnbsystem.uimenu,'Label','Quit','Callback',@exit_Callback,'Accelerator','Q');
       

bnbsystem.uitoolbar = uitoolbar(bnbsystem.mainFig);

[img,map] = imread(fullfile(matlabroot,'toolbox','matlab','icons','matlabicon.gif'));
icon = ind2rgb(img,map);
bnbsystem.register_uipush = uipushtool(bnbsystem.uitoolbar,'TooltipString','Toolbar push button','ClickedCallback','disp(''Clicked uipushtool.'')');
%bnbsystem.register_uipush.CData = icon;
bnbsystem.rois_uipush = uipushtool(bnbsystem.uitoolbar,'TooltipString','Toolbar push button','ClickedCallback','disp(''Clicked uipushtool.'')');
%bnbsystem.rois_uipush.CData = icon;
bnbsystem.extract_uipush = uipushtool(bnbsystem.uitoolbar,'TooltipString','Toolbar push button','ClickedCallback','disp(''Clicked uipushtool.'')');
%bnbsystem.extract_uipush.CData = icon;
bnbsystem.clean_uipush = uipushtool(bnbsystem.uitoolbar,'TooltipString','Toolbar push button','ClickedCallback','disp(''Clicked uipushtool.'')');
%bnbsystem.clean_uipush.CData = icon;
bnbsystem.roisplot_uipush = uipushtool(bnbsystem.uitoolbar,'TooltipString','Toolbar push button','ClickedCallback','disp(''Clicked uipushtool.'')');
%bnbsystem.roisplot_uipush.CData = icon;



bnbsystem.sshdata.userName = 'fcarneva';
bnbsystem.sshdata.hostName = 'bnbdev1.cshl.edu';
bnbsystem.sshdata.password = 'Malasagna1';

bnbsystem.code_folder = 'bnbTP'; %working folder

% try 
%     sshfrommatlabinstall(1)
% catch ME
%     disp(['Could not find sshfrommatlab package. Make sure it is in your path.'])
%     return
% end

disp('Done initialization.')

bnbsystem.exit_btn = uicontrol('Style', 'pushbutton', 'String', 'Exit','Position', [20 20 btn_h btn_v],'Callback', @exit_Callback);

bnbsystem.save_btn = uicontrol('Style', 'pushbutton', 'String', 'Save','Position', [20 60 btn_h btn_v],'Callback', @save_Callback);

bnbsystem.credentials_btn = uicontrol('Style', 'pushbutton', 'String', 'Credentials','Position', [850 450 btn_h btn_v],'Callback', @credentials_Callback);

bnbsystem.results_folder = pwd;
bnbsystem.results_txt = uicontrol('Style','text','String','Results folder','Position', [20 447 100 20]);
bnbsystem.results_edt = uicontrol('Style','edit','String',pwd,'Position', [120 450 450 20],'HorizontalAlignment','left');
bnbsystem.results_btn = uicontrol('Style','pushbutton','String','...','Position', [580 450 30 20],'Callback', @resultfolder_Callback);


bnbsystem.register_btn = uicontrol('Style', 'pushbutton', 'String', 'Register','Position', [20 360 btn_h btn_v],'Callback', @register_Callback);

bnbsystem.rois_btn = uicontrol('Style', 'pushbutton', 'String', 'Draw rois','Position', [20 320 btn_h btn_v],'Callback', @rois_Callback);

bnbsystem.extract_btn = uicontrol('Style', 'pushbutton', 'String', 'Extract','Position', [20 280 btn_h btn_v],'Callback', @extract_Callback);

bnbsystem.clean_btn = uicontrol('Style', 'pushbutton', 'String', 'Clean','Position', [20 240 btn_h btn_v],'Callback', @clean_Callback);

bnbsystem.roisplot_btn = uicontrol('Style', 'pushbutton', 'String', 'Plot rois','Position', [20 200 btn_h btn_v],'Callback', @roisplot_Callback);


function resultfolder_Callback(source,callbackdata)
    
    folder = uigetdir(pwd,'Select results folder');
    if ~isempty(folder)
        bnbsystem.results_edt.String = folder;
        bnbsystem.results_folder = folder;
    end
end

function credentials_Callback(source,callbackdata)

    figure('Visible','on','MenuBar','none','Position',[900 250 300 200],'Name','Set Credentials','NumberTitle','off');
    
    uicontrol('Style','text','String','Username:','Position', [20 147 100 20]);
    username_edt = uicontrol('Style','edit','String',bnbsystem.sshdata.userName,'Position', [120 150 140 20]);
    
    uicontrol('Style','text','String','Hostname:','Position', [20 107 100 20]);
    hostname_edt = uicontrol('Style','edit','String',bnbsystem.sshdata.hostName,'Position', [120 110 140 20]);
    
    uicontrol('Style','text','String','Password:','Position', [20 67 100 20]);
    password_edt = uicontrol('Style','edit','String',bnbsystem.sshdata.password,'Position', [120 70 140 20]);

    save_btn = uicontrol('Style','pushbutton','String','Save','Position', [50 20 100 20],'Callback',@save_Callback);
    cancel_btn = uicontrol('Style','pushbutton','String','Cancel','Position', [170 20 100 20],'Callback',@cancel_Callback);
    
    function save_Callback(source,callbackdata)
        bnbsystem.sshdata.userName = username_edt.String;
        bnbsystem.sshdata.hostName = hostname_edt.String;
        bnbsystem.sshdata.password = password_edt.String;
        close 
    end
    
    function cancel_Callback(source,callbackdata)
        close 
    end
end

function exit_Callback(source,callbackdata)
    close all;
end

function register_Callback(source,callbackdata)
    bnbTP_register;
end

function rois_Callback(source,callbackdata)
    bnbTP_rois;
end

function extract_Callback(source,callbackdata)
    bnbsystem.traces = bnbTP_extract;
    
    channel = 1;
    traces_chan = cell2mat(bnbsystem.traces(:,channel));
    F  = [traces_chan.roisTrace];
    t  = [traces_chan(:).frameTimeStamps];
    figure
    plot(t,F')
% 
% imagesc(F(:,1:20000))
% 
% a={traces(:).roisTrace}';
% s = cellfun('length',a);
% n_neurons = size(a{1,1},1);
% 
% imagesc(a{2,1})

end

function clean_Callback(source,callbackdata)
    bnbTP_clean;
end

function roisplot_Callback(source,callbackdata)
    roisPlot();
end

end