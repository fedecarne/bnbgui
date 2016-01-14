function varargout = make_rois_edge(varargin)
% make_rois_edge MATLAB code for make_rois_edge.fig
%      make_rois_edge, by itself, creates a new make_rois_edge or raises the existing
%      singleton*.
%
%      H = make_rois_edge returns the handle to a new make_rois_edge or the handle to
%      the existing singleton*.
%
%      make_rois_edge('CALLBACK',hObject,eventdata,handles,...) calls the local
%      function named CALLBACK in make_rois_edge.M with the given input arguments.
%
%      make_rois_edge('Property','Value',...) creates a new make_rois_edge or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before make_rois_edge_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to make_rois_edge_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help make_rois_edge

% Last Modified by GUIDE v2.5 13-Jan-2016 16:02:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @make_rois_edge_OpeningFcn, ...
                   'gui_OutputFcn',  @make_rois_edge_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before make_rois_edge is made visible.
function make_rois_edge_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to make_rois_edge (see VARARGIN)

% Choose default command line output for make_rois_edge
handles.output = hObject;

if numel(varargin{1})>0
    
    handles.imageMeanData=varargin{1}.frameMeanMaster;
    handles.imageVarData=varargin{1}.frameVarMaster;
    handles.imageCorrData=varargin{1}.frameCorrMaster;
    
    handles.nFramesData = size(handles.imageMeanData{1,handles.channel_popup.Value},3);
    
    switch handles.image_popup.Value
        case 1
            handles.baseimage = handles.imageMeanData{1,handles.channel_popup.Value}(:,:,1);
        case 2
            handles.baseimage = handles.imageVarData{1,handles.channel_popup.Value};
        case 3
            handles.baseimage = handles.imageCorrData{1,handles.channel_popup.Value}(:,:,1);
    end

    handles.DisplayData = 1;
    handles.nowFrameData=1;
    
    handles.DisplayzStack= 0;
    handles.nowFramezStack=1;
    
    handles.corrimage = handles.imageCorrData(:,:,1);
    
    handles.frameSlider.Max = handles.nFramesData;
    handles.frameSlider.SliderStep=[1/(handles.frameSlider.Max-1) 1/(handles.frameSlider.Max-1)];
    handles.frameSliderIndicator.String=1;
    
    axes(handles.bigAxes);
    
    %initialize brightness and contrast
    handles.contrast_slider.Value = 1./(max(max(handles.baseimage))-min(min(handles.baseimage)));
    handles.bright_slider.Value = 1/2*(1-(max(max(handles.baseimage))+min(min(handles.baseimage)))/(max(max(handles.baseimage))-min(min(handles.baseimage))));
    
    handles.contrast_slider.Max = 10*handles.contrast_slider.Value;
    handles.contrast_slider.Min = 1/10*handles.contrast_slider.Value;
    
    handles.bright_slider.Min = -1;
    handles.bright_slider.Max = 1;
    
    handles.bright_txt.String = handles.bright_slider.Value;
    handles.contrast_txt.String = handles.contrast_slider.Value;
    
    handles.baseimageRGB = handles.baseimage*handles.contrast_slider.Value+handles.bright_slider.Value;
    handles.baseimageRGB = repmat(handles.baseimageRGB,[1,1,3]);

    handles.labelList = {'uncategorized'};
    
    handles.see_roi_current=1;
    
    %%% at the back -- just to keep track
    handles.rois=imagesc(zeros(size(handles.baseimage,1),size(handles.baseimage,2),1));hold on;
    
    %%% second layer -- reference image 
    N = size(handles.baseimageRGB,1);
    M = size(handles.baseimageRGB,2);
    handles.line_offset=0;
    aux = 1:N*M;
    aux = circshift(aux,[0 handles.line_offset]);
    aux(1:handles.line_offset) = 1;
    index = repmat(reshape(aux,[N M]),1,1,3);
    handles.ref_image=image(handles.baseimageRGB(index));

    %%% top layer -- for presantatation popurses
    handles.roi_image=image(zeros(size(handles.baseimage,1),size(handles.baseimage,2),3));axis off
    handles.roi_image.AlphaData=handles.roi_image.CData(:,:,1)==1;
    
    handles.test_val=0;
    handles.LastCoorCalled=[0 0];
    winSize=cell2mat(textscan(handles.smallWinSize.String,'%f'));

    axes(handles.topAxes);
    smallFrame=handles.baseimage(1:winSize(1),1:winSize(2));
    handles.top_image=imagesc(smallFrame);axis off
    colormap('gray')

    axes(handles.lowAxes);
    smallFrame=smallFrame-min(smallFrame(:));
    smallFrame=smallFrame./max(smallFrame(:));
    smallFrameRgb=repmat(smallFrame,[1,1,3]);
    handles.low_image=image(smallFrameRgb);axis off   
    
end

if numel(varargin)>1%% if loading roi file
  
    handles.rois.CData=varargin{2};
    unique(handles.rois.CData) 
    handles.roi_num.String=num2str(max(unique(handles.rois.CData)));
    roi_num=str2double(handles.roi_num.String);

    handles.roi_image.CData(:,:,1)=handles.rois.CData>0;
    handles.roi_image.AlphaData=handles.rois.CData>0;
    handles.roiList.String=[1:roi_num]';

end

handles.rois_data = [];

% Update handles structure
guidata(hObject, handles);
set(handles.figure1,'KeyPressFcn',@setcallbacks);
set(handles.figure1,'WindowScrollWheelFcn',{@figScroll,handles});

handles.mask=[];
set(handles.roi_image,'ButtonDownFcn',{@ImageClickCallback,handles});



function figScroll(src,evnt,handles)
    if evnt.VerticalScrollCount==1
        if handles.frameSlider.Value<size(handles.imageMeanData{1,handles.channel_popup.Value},3)
            handles.frameSlider.Value=handles.frameSlider.Value+1;
        end
    else
        if handles.frameSlider.Value>1
            handles.frameSlider.Value=handles.frameSlider.Value-1;
        end
    end
    frameSlider_Callback(src,1,handles);

% end

function setcallbacks(src,evnt)
    handles = guidata(src);
    hObject = handles.output;
    switch evnt.Key
        case 'f'
            handles.fillCell.Value=~(handles.fillCell.Value);
            mathod_smallWinCenter( hObject , evnt ,handles);
            guidata(hObject, handles);
        case 'd'
            handles.dilateCell.Value=~(handles.dilateCell.Value);
            mathod_smallWinCenter( hObject , evnt ,handles);
            guidata(hObject, handles);
        case 'a'
            add_roi_Callback(hObject,0, handles);
        case 'escape'
        case '1'
            if handles.trsh.Value-.02>str2double(handles.trsh_min.String)
               handles.trsh.Value=handles.trsh.Value-.02;
               handles.trsh_val.String=handles.trsh.Value;
               mathod_smallWinCenter(src,1,handles)
            end
        case '2'
            if handles.trsh.Value+.02<str2double(handles.trsh_max.String)
               handles.trsh.Value=handles.trsh.Value+.02;
               handles.trsh_val.String=handles.trsh.Value;
               mathod_smallWinCenter(src,1,handles)
            end
    end;

% UIWAIT makes make_rois_edge wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = make_rois_edge_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in roiList.
function roiList_Callback(hObject, eventdata, handles)
% hObject    handle to roiList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.roi_image.CData(:,:,2)=0;
handles.roiList.Value;
handles.roi_image.CData(:,:,2)=(handles.rois.CData==handles.roiList.Value)+0;
% Hints: contents = cellstr(get(hObject,'String')) returns roiList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roiList


% --- Executes during object creation, after setting all properties.
function roiList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_roi.
function add_roi_Callback(hObject, eventdata, handles)
% hObject    handle to add_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %%% dont allow if coor were not change from last add roi call
    if ~all(handles.coor==handles.LastCoorCalled)

        handles.LastCoorCalled=handles.coor;

        handles.mask=handles.low_image.CData(:,:,1);
        handles.roi_num.String=str2double(handles.roi_num.String)+1;
        roi_num=str2double(handles.roi_num.String);

        winSize=cell2mat(textscan(handles.smallWinSize.String,'%f'));
        winInd{1}=handles.coor(1)-round(winSize(1)/2)+1:handles.coor(1)+round(winSize(1)/2);
        winInd{2}=handles.coor(2)-round(winSize(2)/2)+1:handles.coor(2)+round(winSize(2)/2);
        winInd{1}(winInd{1}<0 | winInd{1}>size(handles.baseimage,1))=[];
        winInd{2}(winInd{2}<0 | winInd{2}>size(handles.baseimage,2))=[];

        bigmask = zeros(size(handles.baseimage));
        bigmask(winInd{1}(1):winInd{1}(end),winInd{2}(1):winInd{2}(end))=handles.mask*roi_num;        
        
        %%% zero the overlapping indices to prevent overlap
        handles.rois.CData(bigmask>0)=0;
        %%% place the indices in place
        handles.rois.CData=handles.rois.CData+bigmask;        
        
        handles.roi_image.CData(:,:,1)=handles.rois.CData>0;
        handles.roi_image.AlphaData=handles.rois.CData>0;

        handles.roiList.String=[1:roi_num]';
        handles.roiList.Value=roi_num;
        
        guidata(hObject, handles);
    end



% --- Executes on button press in delete_roi.
function delete_roi_Callback(hObject, eventdata, handles)
% hObject    handle to delete_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %%% deleting roi
    handles.rois.CData(handles.rois.CData==handles.roiList.Value)=0;%%% deleting roi
    %%% adjusting indices of roi
    handles.rois.CData(handles.rois.CData>handles.roiList.Value)=handles.rois.CData(handles.rois.CData>handles.roiList.Value)-1;
    % roi list
    handles.roiList.String(end)=[];
    handles.roiList.Value=1;

    % delete the selected roi red mark
    handles.roi_image.CData(:,:,1)=handles.roi_image.CData(:,:,1).*(handles.rois.CData>0);%
    handles.roi_image.CData(:,:,2)=0;%% delete the selected roi mark
    handles.roi_image.AlphaData=(handles.rois.CData>0);

    handles.roi_num.String=str2double(handles.roi_num.String)-1;



% --- Executes on button press in update_roi.
function update_roi_Callback(hObject, eventdata, handles)
% hObject    handle to update_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in label_roi.
function label_roi_Callback(hObject, eventdata, handles)
% hObject    handle to label_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[selection,ok] = listdlg('PromptString','Select a label:','SelectionMode','single','ListString',handles.labelList);
if ok
    handles.roi_label(handles.roiList.Value) = selection;
%     handles.roiList.String = [num2str(handles.roiList.Value) ' (' handles.labelList{selection} ')'];
end
guidata(hObject, handles);



% --- Executes on button press in save
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to save_2_disk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

       
        % save roi_data
        %get neuropil indices
%         neuropil_mask=zeros(size(handles.baseimage));
%         neuropil_mask(winInd{1}(1):winInd{1}(end),winInd{2}(1):winInd{2}(end))=handles.current_neuropil;
%         handles.rois_data(roi_num).neuropil = find(neuropil_mask);
    neuropil_size = 30;

    rois=handles.rois.CData;
    roi_id = unique(rois(rois>0));
    for i=1:size(roi_id,1)
        
        %roi indices
        rois_data(i).roi = find(rois==roi_id(i));
        
        %get neuropil
        s = regionprops(rois==roi_id(i),'centroid');
        rois_data(i).center = round(s.Centroid); % this roi centroid
        
       
        neuropil_mask = zeros(size(rois,1),size(rois,2));
        
        neuropil_mask(rois_data(i).center(2)-neuropil_size/2:rois_data(i).center(2)+neuropil_size/2,rois_data(i).center(1)-neuropil_size/2:rois_data(i).center(1)+neuropil_size/2) = 1;
       
        neuropil_mask(rois>0) = 0;
        
        se90 = strel('line',3, 90);
        se0 = strel('line', 3, 0);
        sdil = imdilate(rois, [se90 se0]);
        dfill = imfill(sdil, 'holes');
        neuropil_mask(dfill>0) = 0;
        
        rois_data(i).neuropil = find(neuropil_mask==1);
    end
                
    rois=handles.rois.CData;
    
    [FileName,PathName] = uiputfile('rois_data.mat','Save file name');
    save([PathName FileName],'rois_data')
    
    [FileName,PathName] = uiputfile('rois.mat','Save file name');
    save([PathName FileName],'rois')

    [FileName,PathName] = uiputfile('rois_fig.mat','Save roi reference image');
    aux = handles.baseimage;
    save([PathName FileName],'aux')

% --- Executes on slider movement.
function frameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.bigAxes);

if handles.DisplayData==1;
    handles.nowFrameData=round(handles.frameSlider.Value);
end
if handles.DisplayzStack==1;
    handles.nowFramezStack=round(handles.frameSlider.Value);
end

    
drawFrame(hObject, handles);
guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function frameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function smallWinSize_Callback(hObject, eventdata, handles)
% hObject    handle to smallWinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smallWinSize as text
%        str2double(get(hObject,'String')) returns contents of smallWinSize as a double


% --- Executes during object creation, after setting all properties.
function smallWinSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smallWinSize (see GCBO)  
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in method.
function method_Callback(hObject, eventdata, handles)

% hObject    handle to method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function trsh_Callback(hObject, eventdata, handles)
% hObject    handle to trsh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.trsh_val.String=handles.trsh.Value;
mathod_smallWinCenter(hObject,1,handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function trsh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trsh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function trsh_min_Callback(hObject, eventdata, handles)
% hObject    handle to trsh_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.trsh.Min = str2double(handles.trsh_min.String);
% Hints: get(hObject,'String') returns contents of trsh_min as text
%        str2double(get(hObject,'String')) returns contents of trsh_min as a double


% --- Executes during object creation, after setting all properties.
function trsh_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trsh_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trsh_max_Callback(hObject, eventdata, handles)
% hObject    handle to trsh_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.trsh.Max = str2double(handles.trsh_max.String);
% Hints: get(hObject,'String') returns contents of trsh_max as text
%        str2double(get(hObject,'String')) returns contents of trsh_max as a double


% --- Executes during object creation, after setting all properties.
function trsh_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trsh_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in dilateCell.
function dilateCell_Callback(hObject, eventdata, handles)
% hObject    handle to dilateCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    mathod_smallWinCenter( hObject , eventdata ,handles);
    guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of dilateCell

% --- Executes on button press in fillCell.
function fillCell_Callback(hObject, eventdata, handles)
% hObject    handle to fillCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    mathod_smallWinCenter( hObject , eventdata ,handles);
    guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of fillCell


function ImageClickCallback( hObject , eventdata ,handles)
    coordinates = get(handles.bigAxes,'CurrentPoint'); %stores last coordinates within the large image
    handles.coor=round([coordinates(1,2),coordinates(1,1)]);
    mathod_smallWinCenter( hObject , eventdata ,handles);
%     % update h and y sliders
%     handles.h_slider.Value = handles.coor(2);
%     handles.h_slider.Min = handles.h_slider.Value-20;
%     handles.h_slider.Max = handles.h_slider.Value+20;
%     handles.y_slider.Value = handles.coor(1);
%     handles.y_slider.Min = handles.y_slider.Value-20;
%     handles.y_slider.Max = handles.y_slider.Value+20;
%     guidata(hObject, handles);


function mathod_smallWinCenter( hObject , eventdata ,handles)
    
if isfield(handles, 'coor')
    
    winSize=cell2mat(textscan(handles.smallWinSize.String,'%f'));
    winInd{1}=handles.coor(1)-round(winSize(1)/2)+1:handles.coor(1)+round(winSize(1)/2);
    winInd{2}=handles.coor(2)-round(winSize(2)/2)+1:handles.coor(2)+round(winSize(2)/2);

    winInd{1}(winInd{1}<0 | winInd{1}>size(handles.baseimage,1))=[];
    winInd{2}(winInd{2}<0 | winInd{2}>size(handles.baseimage,2))=[];

    axes(handles.topAxes);
    
    smallFrame=handles.ref_image.CData(winInd{1},winInd{2},1);
    handles.top_image.CData(1);
    handles.top_image.CData=smallFrame;
    handles.topAxes.XLim=[1 length(winInd{2})];
    handles.topAxes.YLim=[1 length(winInd{1})];

    trsh=handles.trsh.Value;
    option2applay=1;%% increaswe for all option selected

    if handles.dilateCell.Value==1
        options{option2applay}='dilateCell';
        option2applay=option2applay+1;
    else
       options=[];
    end
    
    if handles.fillCell.Value==1
        options{option2applay}='fillCell';
        option2applay=option2applay+1;%%% for future
    end


    [mask neuropil]=findCellInFrame(smallFrame,trsh,options);
    mask=mask==1;
    handles.mask=mask;
    smallFrame=smallFrame-min(smallFrame(:));
    smallFrame=smallFrame./max(smallFrame(:));
    smallFrameRgb=repmat(smallFrame,[1,1,3]);
    smallFrameRgb(:,:,1)=mask;
    
    handles.neuropil=neuropil==1;

    axes(handles.topAxes);
    
    handles.low_image.CData=smallFrameRgb;
    handles.topAxes.XLim=[1 length(winInd{2})];
    handles.topAxes.YLim=[1 length(winInd{1})];
    handles.lowAxes.XLim=[1 length(winInd{2})];
    handles.lowAxes.YLim=[1 length(winInd{1})];
    
    set(handles.low_image,'ButtonDownFcn',{@LowImageClickCallback,handles});
    
    guidata(hObject,handles);
end


% --- Executes on button press in exit_button.
function exit_button_Callback(hObject, eventdata, handles)
% hObject    handle to exit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
closereq


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over trsh.
function trsh_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to trsh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% % --- Executes on mouse press over axes background.
 function LowImageClickCallback(hObject, eventdata, handles)
% % hObject    handle to lowAxes (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
coordinates = get(handles.lowAxes,'CurrentPoint'); %stores last coordinates within the large image
coordinates = round([coordinates(1,1),coordinates(1,2)]);
handles.low_image.CData(coordinates(2),coordinates(1),1) = ~handles.low_image.CData(coordinates(2),coordinates(1),1);
guidata(hObject,handles);


function bright_txt_Callback(hObject, eventdata, handles)
% hObject    handle to bright_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bright_txt as text
%        str2double(get(hObject,'String')) returns contents of bright_txt as a double


% --- Executes during object creation, after setting all properties.
function bright_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bright_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function bright_slider_Callback(hObject, eventdata, handles)
% hObject    handle to bright_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.bigAxes);
    handles.bright_txt.String = handles.bright_slider.Value;

    drawFrame(hObject,handles)
    
%     handles.baseimageRGB = handles.baseimage*handles.contrast_slider.Value+handles.bright_slider.Value;
%     handles.baseimageRGB = repmat(handles.baseimageRGB,[1,1,3]);
%     handles.ref_image.CData=handles.baseimageRGB;
%     
%     guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function bright_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bright_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function contrast_slider_Callback(hObject, eventdata, handles)
% hObject    handle to contrast_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.bigAxes);
    handles.contrast_txt.String = handles.contrast_slider.Value;

        drawFrame(hObject,handles)

        
%     handles.baseimageRGB = handles.baseimage*handles.contrast_slider.Value+handles.bright_slider.Value;
%     handles.baseimageRGB = repmat(handles.baseimageRGB,[1,1,3]);
%     handles.ref_image.CData=handles.baseimageRGB;
%     
%     guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function contrast_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrast_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function contrast_txt_Callback(hObject, eventdata, handles)
% hObject    handle to contrast_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of contrast_txt as text
%        str2double(get(hObject,'String')) returns contents of contrast_txt as a double


% --- Executes during object creation, after setting all properties.
function contrast_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrast_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Scales brightness and contrast of current image
function imscale(hObject,handles)
    axes(handles.bigAxes);
    
    handles.contrast_slider.Value = 1./(max(max(handles.baseimage))-min(min(handles.baseimage)));
    handles.bright_slider.Value = 1/2*(1-(max(max(handles.baseimage))+min(min(handles.baseimage)))/(max(max(handles.baseimage))-min(min(handles.baseimage))));
    
    handles.contrast_slider.Max = 10*handles.contrast_slider.Value;
    handles.contrast_slider.Min = 1/10*handles.contrast_slider.Value;
    
    handles.bright_slider.Min = -1;
    handles.bright_slider.Max = 1;
    
    handles.bright_txt.String = handles.bright_slider.Value;
    handles.contrast_txt.String = handles.contrast_slider.Value;

    handles.baseimageRGB = handles.baseimage*handles.contrast_slider.Value+handles.bright_slider.Value;
    handles.baseimageRGB = repmat(handles.baseimageRGB,[1,1,3]);
    handles.ref_image.CData = handles.baseimageRGB;
    
    guidata(hObject, handles);


% --- Executes on button press in imscale_btn.
function imscale_btn_Callback(hObject, eventdata, handles)
% hObject    handle to imscale_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    imscale(hObject,handles);
    


% --- Executes on selection change in image_popup.
function image_popup_Callback(hObject, eventdata, handles)
% hObject    handle to image_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.bigAxes);

switch handles.image_popup.Value
    case 1
        handles.baseimage=handles.imageMeanData{1,handles.channel_popup.Value}(:,:,handles.nowFrameData);
    case 2
        handles.baseimage=handles.imageVarData{1,handles.channel_popup.Value};
    case 3
        handles.baseimage=handles.imageCorrData{1,handles.channel_popup.Value}(:,:,handles.nowFrameData);
end

handles.baseimageRGB = handles.baseimage*handles.contrast_slider.Value+handles.bright_slider.Value;
handles.baseimageRGB = repmat(handles.baseimageRGB,[1,1,3]);

handles.ref_image.CData=handles.baseimageRGB;
% set(handles.ref_image,'ButtonDownFcn',{@ImageClickCallback,handles});

guidata(hObject, handles);
imscale(hObject, handles);


% --- Executes during object creation, after setting all properties.
function image_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function h_slider_Callback(hObject, eventdata, handles)
% hObject    handle to h_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
d = get(hObject,'Value');
handles.coor(2) = round(d);
mathod_smallWinCenter( hObject , eventdata ,handles);
guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function h_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to h_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function y_slider_Callback(hObject, eventdata, handles)
% hObject    handle to y_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
d = get(hObject,'Value');
handles.coor(1) = (handles.y_slider.Min + handles.y_slider.Max) - d;
mathod_smallWinCenter( hObject , eventdata ,handles);
guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function y_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function channel_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Channel_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Channel_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function channel_popup_Callback(hObject, eventdata, handles)
% hObject    handle to Channel_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
axes(handles.bigAxes);
drawFrame(hObject, handles);





% --- Executes on slider movement.
function lineoffsetSlider_Callback(hObject, eventdata, handles)
% hObject    handle to lineoffsetSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.bigAxes);
handles.line_offset=round(get(hObject,'Value'));

handles.lineoffsetText.String = num2str(round(get(hObject,'Value')));

N = size(handles.baseimageRGB,1);
M = size(handles.baseimageRGB,2);

n_pix = handles.line_offset;
index = 1:N*M;
index = reshape(index,[N M])';
index_shifted=index;

% odd=circshift(index(:,1:2:end),[n_pix 0]);odd(1:n_pix,:)=[ones(n_pix,1) index(1:n_pix,2:2:end-1)];
% even=circshift(index(:,2:2:end),[-n_pix 0]);even(end-n_pix+1:end,:)= flip(index(end-n_pix+1:end,1:2:end-1),2);

odd = index(:,1:2:end);
even=circshift(index(:,2:2:end),[n_pix 0]);
index_shifted(:,1:2:end) = odd;
index_shifted(:,2:2:end) = even;
index_shifted = repmat(index_shifted',1,1,3);
handles.ref_image=image(handles.baseimageRGB(index_shifted));
set(handles.ref_image,'ButtonDownFcn',{@ImageClickCallback,handles});

% --- Executes during object creation, after setting all properties.
function lineoffsetSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineoffsetSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function Channel_panel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Channel_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function Channel_panel_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Channel_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in data_btn.
function data_btn_Callback(hObject, eventdata, handles)
% hObject    handle to data_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.DisplayData=1;
handles.DisplayzStack=0;
guidata(hObject, handles);
drawFrame(hObject, handles);


% --- Executes on button press in zstack_btn.
function zstack_btn_Callback(hObject, eventdata, handles)
% hObject    handle to zstack_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.DisplayData=0;
handles.DisplayzStack=1;

if ~isfield(handles,'imageMeanzStack')
    [FileName,PathName,FilterIndex] = uigetfile('*.mat','Select zstack file', [pwd '/reg_zstack.mat']);
    if FileName==0
        return
    end
    frameMaster = prepareframeMaster([PathName FileName]);    
        
    handles.imageMeanzStack = frameMaster.frameMeanMaster;
    handles.imageVarzStack = frameMaster.frameVarMaster;
    handles.imageCorrzStack = frameMaster.frameCorrMaster;
    
    handles.nFrameszStack = size(handles.imageMeanzStack{1,handles.channel_popup.Value},3);
    handles.nowFramezStack = 1;
end
drawFrame(hObject, handles);


function drawFrame(hObject,handles)
        
switch handles.image_popup.Value
    case 1
        if ~isempty(handles.imageMeanData{1,handles.channel_popup.Value})
            handles.baseimage=handles.imageMeanData{1,handles.channel_popup.Value}(:,:,handles.nowFrameData);
        else
            handles.baseimage = 0.95*ones(size(handles.baseimage,1),size(handles.baseimage,2));
            handles.baseimageRGB = repmat(handles.baseimage,[1,1,3]);
            handles.ref_image.CData=handles.baseimageRGB;
        end
        if handles.DisplayzStack==1
            if handles.nowFramezStack<=handles.nFrameszStack
                handles.baseimage=handles.imageMeanzStack{1,handles.channel_popup.Value}(:,:,handles.nowFramezStack);
            else
                handles.baseimage=handles.imageMeanzStack{1,handles.channel_popup.Value}(:,:,end);
            end
        end
    case 2
        if ~isempty(handles.imageVarData{1,handles.channel_popup.Value})
            handles.baseimage=handles.imageVarData{1,handles.channel_popup.Value};
        else
            handles.baseimage = 0.95*ones(size(handles.baseimage,1),size(handles.baseimage,2));
            handles.baseimageRGB = repmat(handles.baseimage,[1,1,3]);
            handles.ref_image.CData=handles.baseimageRGB;
        end
        if handles.DisplayzStack==1
            if handles.nowFramezStack<=handles.nFrameszStack
                handles.baseimage=handles.imageVarzStack{1,handles.channel_popup.Value}(:,:,1);
            end
        end
    case 3
        if ~isempty(handles.imageCorrData{1,handles.channel_popup.Value})
            handles.baseimage=handles.imageCorrData{1,handles.channel_popup.Value}(:,:,handles.nowFrameData);
        else
            handles.baseimage = 0.95*ones(size(handles.baseimage,1),size(handles.baseimage,2));
            handles.baseimageRGB = repmat(handles.baseimage,[1,1,3]);
            handles.ref_image.CData=handles.baseimageRGB;
        end
        if handles.DisplayzStack==1
            if handles.nowFrameData<=handles.nFrameszStack
                handles.baseimage=handles.imageCorrzStack{1,handles.channel_popup.Value}(:,:,handles.nowFramezStack);
            else
                handles.baseimage=handles.imageCorrzStack{1,handles.channel_popup.Value}(:,:,end);
            end
        end
end

if handles.DisplayData==1
    handles.frameSliderIndicator.String = handles.nowFrameData;
    handles.frameSlider.Value =  handles.nowFrameData;
end
if handles.DisplayzStack==1
    handles.frameSliderIndicator.String=handles.nowFramezStack;
    handles.frameSlider.Value =  handles.nowFramezStack;
end
    
handles.baseimageRGB = handles.baseimage*handles.contrast_slider.Value+handles.bright_slider.Value;
handles.baseimageRGB = repmat(handles.baseimageRGB,[1,1,3]);

handles.ref_image.CData=handles.baseimageRGB;
set(handles.roi_image,'ButtonDownFcn',{@ImageClickCallback,handles});
guidata(hObject, handles);

        


% --- Executes on button press in see_roi.
function see_roi_Callback(hObject, eventdata, handles)
% hObject    handle to see_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of see_roi

if handles.see_roi_current;
    handles.roi_image.Visible='Off'; 
    handles.see_roi_current=0;
else
    hObject.Value = 1;
    handles.roi_image.Visible='On'; 
	handles.see_roi_current=1;
end
guidata(hObject, handles);



% --- Executes on button press in add_label.
function add_label_Callback(hObject, eventdata, handles)
% hObject    handle to add_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = inputdlg('New label name','Add label');
if ~isempty(answer)
    handles.labelList(size(handles.labelList,2)+1) = answer;
end
guidata(hObject, handles);
