function varargout = relabelGUI(varargin)
% RELABELGUI MATLAB code for relabelGUI.fig
%      RELABELGUI, by itself, creates a new RELABELGUI or raises the existing
%      singleton*.
%
%      H = RELABELGUI returns the handle to a new RELABELGUI or the handle to
%      the existing singleton*.
%
%      RELABELGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RELABELGUI.M with the given input arguments.
%
%      RELABELGUI('Property','Value',...) creates a new RELABELGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before relabelGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to relabelGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help relabelGUI

% Last Modified by GUIDE v2.5 05-Nov-2015 13:36:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @relabelGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @relabelGUI_OutputFcn, ...
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



% --- Executes just before relabelGUI is made visible.
function relabelGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to relabelGUI (see VARARGIN)

annotation_mat = get(handles.LoadAnnotations,'String');
annotation_mat = strtrim(annotation_mat);
load([annotation_mat]);
[trash, numrows] = size(annotations);
targets = {};
start = 1;
nextkey = 1;
for i=1:numrows
   if annotations{i}.id ~= annotations{start}.id
       targets{nextkey} = [annotations{start:i-1}];
       start = i;
       nextkey = nextkey +1;
   elseif i == numrows
       targets{nextkey} = [annotations{start:i-1}];
   end
end

[frames_path_base, trash] = fileparts(annotation_mat);
frames_path_txt = fullfile(frames_path_base,'paths.txt');
fid = fopen(frames_path_txt);
frames_path = fgetl(fid);
fclose(fid);

frameslist = dir(frames_path);
frameslist = frameslist(3:end);
[frameslist, trash] = sort({frameslist(:).name});

first_frame_path = fullfile(frames_path,char(frameslist(1)));
first_frame = imread(first_frame_path);
axes(handles.axes1);
imshow(first_frame);


[trash, ktargets] = size(targets);
%[from_x from_y width height]
box = targets{1}(1);
height = box.xbr - box.xtl;
width = box.ybr - box.ytl;
x = mean([box.xbr box.xtl]);
y = mean([box.ybr box.ytl]);
%hold on;
%plot(x,y,'b.','MarkerSize',10);
hold on;
rectangle('Position', [box.xtl, box.ytl, height, width],'EdgeColor','r', 'LineWidth', 3);


[trash, kframes] = size(frameslist);


handles.targets = targets;
handles.ktargets = ktargets;
handles.currentTarget = 1;
handles.frameslist = frameslist;
handles.kframes = kframes;
handles.framespath = frames_path;


%set the label
set(handles.Label, 'String', handles.targets{handles.currentTarget}(1).label);



% Choose default command line output for relabelGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes relabelGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = relabelGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

idx = get(handles.slider1,'Value'); %between [0,1];
current_frame = cast(idx*(handles.kframes-1),'uint16') + 1;
frameslist = handles.frameslist;

frame_path = fullfile(handles.framespath,char(frameslist(current_frame)));
frame = imread(frame_path);
cla(handles.axes1,'reset');
axes(handles.axes1);
imshow(frame);

trackx = [];
tracky = [];
current_target_boxes = handles.targets{handles.currentTarget};
[trash, kboxes] = size(current_target_boxes);
box_frame = 1; %1 indexed.
idx = 1;
while box_frame < current_frame-1 && idx <= kboxes
    box = current_target_boxes(idx);
    if box.lost == 0 %box is not lost (its in bounds).
        x = mean([box.xbr box.xtl]);
        y = mean([box.ybr box.ytl]);
        trackx = [trackx; x];
        tracky = [tracky; y];
        box_frame = box.frame;
        idx = idx + 1;
    end
end

if idx > kboxes
    idx = idx -1;
end
box = current_target_boxes(idx);
height = box.xbr - box.xtl;
width = box.ybr - box.ytl;

[tracklen, trash] = size(trackx);
hold on;
if box.lost == 0
    trackx_ = [];
    tracky_ = [];
    for i=1:tracklen
       x = trackx(i);
       y = tracky(i);
       %if (x,y) is inside the bounding box, then remove it from the list.
       if x >= box.xbr || x <= box.xtl || y >= box.ybr || y <= box.ytl
           trackx_ = [trackx_; x];
           tracky_ = [tracky_; y];
       end
    end
    plot(trackx_,tracky_,'r.','MarkerSize',10);
    hold on;
    rectangle('Position', [box.xtl, box.ytl, height, width],'EdgeColor','r', 'LineWidth', 3);
else
    plot(trackx,tracky,'r.','MarkerSize',10);
end




% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%%image = 'path to image';
%%axes(handles.axis1);
%%imshow(image);




function label_Callback(hObject, eventdata, handles)
% hObject    handle to label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of label as text
%        str2double(get(hObject,'String')) returns contents of label as a double


% --- Executes during object creation, after setting all properties.
function label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NextTarget.
function NextTarget_Callback(hObject, eventdata, handles)
% hObject    handle to NextTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newTarget = handles.currentTarget +1;
if newTarget > handles.ktargets
    newTarget = 1;
end
handles.currentTarget = newTarget;
guidata(hObject, handles);
slider1_Callback(hObject, eventdata, handles);
set(handles.Label, 'String', handles.targets{handles.currentTarget}(1).label);
%slider1_Callback(hObject, eventdata, handles);






function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SaveImage.
function SaveImage_Callback(hObject, eventdata, handles)
% hObject    handle to SaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
F = getframe(handles.axes1);
Image = frame2im(F);
savePath = get(handles.saveFramePath,'String');
imwrite(Image, savePath);


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
contents = cellstr(get(hObject,'String'));
label = contents{get(hObject,'Value')};
target = handles.targets{handles.currentTarget};
[trash, kboxes] = size(target);
for i=1:kboxes
   handles.targets{handles.currentTarget}(i).label = label; 
end
guidata(hObject, handles);
set(handles.Label, 'String', handles.targets{handles.currentTarget}(1).label);


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function uipanel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in PreviousTarget.
function PreviousTarget_Callback(hObject, eventdata, handles)
% hObject    handle to PreviousTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newTarget = handles.currentTarget -1;
if newTarget < 1
    newTarget = handles.ktargets;
end
handles.currentTarget = newTarget;
guidata(hObject, handles);
slider1_Callback(hObject, eventdata, handles);
set(handles.Label, 'String', handles.targets{handles.currentTarget}(1).label);


% --- Executes during object creation, after setting all properties.
function Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function saveDataMat_Callback(hObject, eventdata, handles)
% hObject    handle to saveDataMat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of saveDataMat as text
%        str2double(get(hObject,'String')) returns contents of saveDataMat as a double


% --- Executes during object creation, after setting all properties.
function saveDataMat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveDataMat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function saveFramePath_Callback(hObject, eventdata, handles)
% hObject    handle to saveFramePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of saveFramePath as text
%        str2double(get(hObject,'String')) returns contents of saveFramePath as a double
%handles.saveImagePath = get(hObject, 'String');
%guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function saveFramePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveFramePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LoadAnnotations_Callback(hObject, eventdata, handles)
% hObject    handle to LoadAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LoadAnnotations as text
%        str2double(get(hObject,'String')) returns contents of LoadAnnotations as a double






% --- Executes during object creation, after setting all properties.
function LoadAnnotations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadVideo.
function LoadVideo_Callback(hObject, eventdata, handles)
% hObject    handle to LoadVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

annotation_mat = get(handles.LoadAnnotations,'String');
annotation_mat = strtrim(annotation_mat);

load([annotation_mat]);
[trash, numrows] = size(annotations);
targets = {};
start = 1;
nextkey = 1;
for i=1:numrows
   if annotations{i}.id ~= annotations{start}.id
       targets{nextkey} = [annotations{start:i-1}];
       start = i;
       nextkey = nextkey +1;
   elseif i == numrows
       targets{nextkey} = [annotations{start:i-1}];
   end
end

[frames_path_base, trash] = fileparts(annotation_mat);
frames_path_txt = fullfile(frames_path_base,'paths.txt');
fid = fopen(frames_path_txt);
frames_path = fgetl(fid);
fclose(fid);

frameslist = dir(frames_path);
frameslist = frameslist(3:end);
[frameslist, trash] = sort({frameslist(:).name});

first_frame_path = fullfile(frames_path,char(frameslist(1)));
first_frame = imread(first_frame_path);
cla(handles.axes1,'reset');
axes(handles.axes1);
imshow(first_frame);


[trash, ktargets] = size(targets);
%[from_x from_y width height]
box = targets{1}(1);
height = box.xbr - box.xtl;
width = box.ybr - box.ytl;
x = mean([box.xbr box.xtl]);
y = mean([box.ybr box.ytl]);
%hold on;
%plot(x,y,'b.','MarkerSize',10);
hold on;
rectangle('Position', [box.xtl, box.ytl, height, width],'EdgeColor','r', 'LineWidth', 3);


[trash, kframes] = size(frameslist);


handles.targets = targets;
handles.ktargets = ktargets;
handles.currentTarget = 1;
handles.frameslist = frameslist;
handles.kframes = kframes;
handles.framespath = frames_path;


%set the label
set(handles.Label, 'String', handles.targets{handles.currentTarget}(1).label);

guidata(hObject, handles);
