function varargout = alexGUI(varargin)
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

% Last Modified by GUIDE v2.5 06-Nov-2015 10:34:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @alexGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @alexGUI_OutputFcn, ...
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
function alexGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to relabelGUI (see VARARGIN)
%load('/scr/alexr/main7resultUAVSVM_2.mat');


load('main7resultUAVSVM_2.mat');
%Primarily will manipulate Res and D.
%The three methods are: 1, 2, 9


%handle variables.
currentVideo = 1;
currentSimulation = 0;
videosDir = '/cvgl/group/UAV_data/6-annotations-simple/';

scene_video = D(currentVideo).label;
[scene_video] = strsplit(scene_video,'_');
scene = scene_video(1);
video = scene_video(2);
videoDir = fullfile(videosDir,scene,video);
frames_path_txt = fullfile(videoDir,'paths.txt');
fid = fopen(char(frames_path_txt));
framespath = fgetl(fid);
fclose(fid);
frameslist = dir(framespath);
frameslist = frameslist(3:end);
[frameslist, trash] = sort({frameslist(:).name});

%Show the frame corresponding to this simulation.
frame_path = fullfile(framespath,char(frameslist(1)));


cla(handles.axes1,'reset');
show_frame = imread(frame_path);
axes(handles.axes1);
imshow(show_frame);
%set the video text label
set(handles.VideoText, 'String', scene_video);
set(handles.simNumber, 'String', currentSimulation);



%Set the handles.
handles.currentVideo = currentVideo;
handles.currentSimulation = currentSimulation;
handles.videosDir = videosDir;
handles.methods = [1, 2, 9];
handles.framespath = framespath;
handles.D = D;
handles.Res = Res;
handles.frameslist = frameslist;

% Choose default command line output for relabelGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes relabelGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = alexGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in NextPrediction.
function NextPrediction_Callback(hObject, eventdata, handles)
% hObject    handle to NextPrediction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

currentSimulation = handles.currentSimulation+1;
currentVideo = handles.currentVideo;
videosDir = handles.videosDir;
methods = handles.methods;
framespath = handles.framespath;
D = handles.D;
Res = handles.Res;
frameslist = handles.frameslist;

[trash, kmethods] = size(methods);
cellX = {};
cellY = {};
for i=1:kmethods
  cellX{methods(i)} = [];
  cellY{methods(i)} = [];
end;

cellX_GT = [];
cellY_GT = [];

%Get the  next simulation.
H = D(currentVideo).H;
hx = H(1,1);
hy = H(2,2);

frame_number = 0;

[simLines, trash] = size(Res{currentVideo}{methods(1)});

for idx = 1:simLines
  if Res{currentVideo}{methods(1)}(idx,1) == currentSimulation
    if frame_number == 0
      frame_number = Res{currentVideo}{methods(1)}(idx,2);
    end;

    for i=1:kmethods
      px = Res{currentVideo}{methods(i)}(idx,4);
      px_ = round(px/hx);
      py = Res{currentVideo}{methods(i)}(idx,5);
      py_ = round(py/hy);

      cellX{methods(i)} = [cellX{methods(i)}; px_];
      cellY{methods(i)} = [cellY{methods(i)}; py_];

      %Find this 
    end
    this_id = Res{currentVideo}{methods(1)}(idx,3);
    %this_id = Res{currentVideo}{methods(1)}(idx,2);
    %frame number changes.
    this_frame = Res{currentVideo}{methods(1)}(idx,2);
    %this_frame = Res{currentVideo}{methods(1)}(idx,3);


    %find this_id in the D(currentVideo).observations table
    [D_obs_rows, trash] = size(D(currentVideo).observations);
    % (frame, id, x, y)
    for r=1:D_obs_rows
      row = D(currentVideo).observations(r,:);
      if row(1) == this_frame && row(2) == this_id
        cellX_GT = [cellX_GT, round(row(3)/hx)];
        cellY_GT = [cellY_GT, round(row(4)/hy)];
        break;
      end;
    end

  end
end



%Show the frame corresponding to this simulation.
frame_path = fullfile(framespath,char(frameslist(frame_number)));


cla(handles.axes1,'reset');
show_frame = imread(frame_path);
axes(handles.axes1);
imshow(show_frame);


%Plot the 3 methods for this simulation.
colors = ['y', 'r','b'];

for i=1:kmethods
  x = cellX{methods(i)};
  y = cellY{methods(i)};
  hold on;
  plot(x,y,[colors(i),'o-'],'MarkerFaceColor',colors(i),'MarkerSize', 2);
end;

%PLOT THE GROUND TRUTH.
hold on;
plot(cellX_GT,cellY_GT,'go-','MarkerFaceColor','g','MarkerSize', 2);

set(handles.simNumber, 'String', currentSimulation);
handles.currentSimulation = currentSimulation;
guidata(hObject, handles);






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



% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1




% --- Executes during object creation, after setting all properties.
function uipanel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in PreviousPrediction.
function PreviousPrediction_Callback(hObject, eventdata, handles)
% hObject    handle to PreviousPrediction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.currentSimulation <= 1
  handles.currentSimulation = 0;
else
  handles.currentSimulation = handles.currentSimulation - 2;
end
guidata(hObject, handles);





function saveFramePath_Callback(hObject, eventdata, handles)
% hObject    handle to saveFramePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of saveFramePath as text
%        str2double(get(hObject,'String')) returns contents of saveFramePath as a double




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



% --- Executes on button press in NextVideo.
function NextVideo_Callback(hObject, eventdata, handles)
% hObject    handle to NextVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

D = handles.D;
Res = handles.Res;
currentVideo = handles.currentVideo;

%handle variables.
currentVideo = currentVideo + 1;
if currentVideo == 24
  currentVideo = 1
end;
videosDir = '/cvgl/group/UAV_data/6-annotations-simple/';
scene_video = D(currentVideo).label;
[scene_video] = strsplit(scene_video,'_');
scene = scene_video(1);
video = scene_video(2);
videoDir = fullfile(videosDir,scene,video);
frames_path_txt = fullfile(videoDir,'paths.txt');
fid = fopen(char(frames_path_txt));
framespath = fgetl(fid);
fclose(fid);
frameslist = dir(framespath);
frameslist = frameslist(3:end);
[frameslist, trash] = sort({frameslist(:).name});

%Show the frame corresponding to this simulation.
frame_path = fullfile(framespath,char(frameslist(1)));
cla(handles.axes1,'reset');
show_frame = imread(frame_path);
axes(handles.axes1);
imshow(show_frame);
%set the video text label
set(handles.VideoText, 'String', scene_video);
currentSimulation = 0;
set(handles.simNumber, 'String', currentSimulation);



%Set the handles.
handles.currentVideo = currentVideo;
handles.currentSimulation = currentSimulation;
handles.videosDir = videosDir;
handles.framespath = framespath;
handles.frameslist = frameslist;


guidata(hObject, handles);








% --- Executes on button press in PreviousVideo.
function PreviousVideo_Callback(hObject, eventdata, handles)
% hObject    handle to PreviousVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

D = handles.D;
Res = handles.Res;
currentVideo = handles.currentVideo;

%handle variables.
currentVideo = currentVideo-1;
if currentVideo == 0
  currentVideo = 23
end;
videosDir = '/cvgl/group/UAV_data/6-annotations-simple/';
scene_video = D(currentVideo).label;
[scene_video] = strsplit(scene_video,'_');
scene = scene_video(1);
video = scene_video(2);
videoDir = fullfile(videosDir,scene,video);
frames_path_txt = fullfile(videoDir,'paths.txt');
fid = fopen(char(frames_path_txt));
framespath = fgetl(fid);
fclose(fid);
frameslist = dir(framespath);
frameslist = frameslist(3:end);
[frameslist, trash] = sort({frameslist(:).name});

%Show the frame corresponding to this simulation.
frame_path = fullfile(framespath,char(frameslist(1)));
cla(handles.axes1,'reset');
show_frame = imread(frame_path);
axes(handles.axes1);
imshow(show_frame);
%set the video text label
set(handles.VideoText, 'String', scene_video);
currentSimulation = 0;
set(handles.simNumber, 'String', currentSimulation);



%Set the handles.
handles.currentVideo = currentVideo;
handles.currentSimulation = currentSimulation;
handles.videosDir = videosDir;
handles.framespath = framespath;
handles.frameslist = frameslist;
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function VideoText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VideoText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
