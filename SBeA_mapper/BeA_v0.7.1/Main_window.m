function varargout = Main_window(varargin)
% MAIN_WINDOW MATLAB code for Main_window.fig
%      MAIN_WINDOW, by itself, creates a new MAIN_WINDOW or raises the existing
%      singleton*.
%
%      H = MAIN_WINDOW returns the handle to a new MAIN_WINDOW or the handle to
%      the existing singleton*.
%
%      MAIN_WINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_WINDOW.M with the given input arguments.
%
%      MAIN_WINDOW('Property','Value',...) creates a new MAIN_WINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Main_window_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_window_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Main_window

% Last Modified by GUIDE v2.5 20-Mar-2020 01:21:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Main_window_OpeningFcn, ...
                   'gui_OutputFcn',  @Main_window_OutputFcn, ...
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


% --- Executes just before Main_window is made visible.
function Main_window_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Main_window (see VARARGIN)

% Choose default command line output for Main_window
handles.output = hObject; 
axes(handles.axes2)
imshow(255)
movegui(gcf,'center');
addpath('./src')
addpath('./import')
addpath('./preprocess')
addpath('./lib')
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Main_window wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Main_window_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_file_open_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HBT
[filename,pathname]=uigetfile({'*.mat';'*.*'},'Load Data');
load(fullfile(pathname,filename));
msgbox('Data imported','modal')


% --------------------------------------------------------------------
function menu_file_imvideo_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_imvideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HBT video_key
[filename,pathname]=uigetfile({'*.mp4';'*.avi';'*.*'},'Select Veido');
import_video(fullfile(pathname,filename)); 
set(handles.time_end,'string',datestr(seconds(HBT.DataInfo.VideoInfo.Duration),'HH:MM:SS.FFF'))
set(handles.duration_text,'string',datestr(seconds(HBT.DataInfo.VideoInfo.Duration),'HH:MM:SS.FFF'))
set(handles.framerate_text,'string',num2str(round(HBT.DataInfo.VideoInfo.FrameRate)))
set(handles.radiobutton2,'enable','off')
msgbox('Video imported','modal')
video_key.nowframe=1;


% --------------------------------------------------------------------
function menu_file_imdata_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_imdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_file_imevents_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_imevents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HBT
[filename,pathname]=uigetfile({'*.txt';'*.csv';'*.*'},'Select Events');
 import_event(fullfile(pathname,filename))
 msgbox('Events imported','modal')
 set(handles.events_text,'string',num2str(size(HBT.Exp_Info.Event,2)));
 

% --------------------------------------------------------------------
function menu_file_exits_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_exits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = questdlg('Save data?', ...
	'exit', ...
	'Yes','No thank you','No thank you');
% Handle response
switch answer
    case 'Yes'
         close(gcf)
    case 'No thank you'
        close(gcf)
end


% --------------------------------------------------------------------
function menu_file_imdata_deep_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_imdata_deep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HBT video_key
%% transform dlc_csv_name to path and name
video_key.status=3;
[filename,pathname]=uigetfile({'*.csv';'*.txt';'*.*'},'Select Data');
dlc_csv_name=fullfile(pathname,filename);
import_dlc(dlc_csv_name)
set(handles.radiobutton2,'enable','on');
try HBT.DataInfo.VideoInfo.Duration;
set(handles.time_end,'string',datestr(seconds(HBT.DataInfo.VideoInfo.Duration),'HH:MM:SS.FFF'))
set(handles.duration_text,'string',datestr(seconds(HBT.DataInfo.VideoInfo.Duration),'HH:MM:SS.FFF'))
set(handles.framerate_text,'string',num2str(round(HBT.DataInfo.VideoInfo.FrameRate)))
catch
   video_key.showVideo=0; 
end
set(handles.slider1,'max',round(size(HBT.RawData.X, 1)),'enable','on');
video_play_with_data_figfun(handles)
%% import data

% --------------------------------------------------------------------
function menu_file_imdata_pos_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_imdata_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_preprocess_Callback(hObject, eventdata, handles)
% hObject    handle to menu_preprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_preprocess_correction_Callback(hObject, eventdata, handles)
% hObject    handle to menu_preprocess_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HBT
h=artfical_correction;
uiwait(h) 
if exist('./tmp_data/artfical_data.mat','file')==0
    msgbox('No method can apply');
else
load('./tmp_data/artfical_data.mat');
method=artfical_data.method;
WinWD=artfical_data.wd;
artifact_correction(method, WinWD);
delete('./tmp_data/artfical_data.mat');
end


% --------------------------------------------------------------------
function menu_preprocess_smooth_Callback(hObject, eventdata, handles)
% hObject    handle to menu_preprocess_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HBT
h=Smoothing
uiwait(h) 
if exist('./tmp_data/smooth_data.mat','file')==0
    msgbox('No method can apply');
else
load('./tmp_data/smooth_data.mat');
artifact_correction(smooth_data);
delete('./tmp_data/smooth_data.mat');
end

% --------------------------------------------------------------------
function menu_preprocess_cut_Callback(hObject, eventdata, handles)
% hObject    handle to menu_preprocess_cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=Cut_Data
uiwait(h) 
if exist('./tmp_data/CutData.mat','file')==0
    msgbox('could not cut data');
else
load('./tmp_data/CutData.mat');
cut_data(CutData)
delete('./tmp_data/CutData.mat');
end
% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_tools_bmap_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools_bmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Behavior_Mapping

% --------------------------------------------------------------------
function menu_tools_ba_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools_ba (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_tools_plotHM_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools_plotHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Plot_HeatMap

% --------------------------------------------------------------------
function menu_tools_plotVM_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools_plotVM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Plot_VelocityMap

% --------------------------------------------------------------------
function menu_tools_plotE_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools_plotE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Plot_Ethograms

% --------------------------------------------------------------------
function menu_tools_DW_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools_DW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Decomposing_Viewer

% --------------------------------------------------------------------
function menu_analysis_de_Callback(hObject, eventdata, handles)
% hObject    handle to menu_analysis_de (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Behavior_Decomposing

% --------------------------------------------------------------------
function menu_analysis_fre_Callback(hObject, eventdata, handles)
% hObject    handle to menu_analysis_fre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Calculating_Freezing

% --------------------------------------------------------------------
function menu_analysis_fli_Callback(hObject, eventdata, handles)
% hObject    handle to menu_analysis_fli (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Calculating_Flighting

% --------------------------------------------------------------------
function menu_tools_ba_ml_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools_ba_ml (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Movement_Layer

% --------------------------------------------------------------------
function menu_tools_ba_el_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools_ba_el (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Ethograms_Layer

% --------------------------------------------------------------------
function menu_result_Callback(hObject, eventdata, handles)
% hObject    handle to menu_result (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_result_ebdr_Callback(hObject, eventdata, handles)
% hObject    handle to menu_result_ebdr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_result_ebar_Callback(hObject, eventdata, handles)
% hObject    handle to menu_result_ebar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_result_eerar_Callback(hObject, eventdata, handles)
% hObject    handle to menu_result_eerar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_info_Callback(hObject, eventdata, handles)
% hObject    handle to menu_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_info_version_Callback(hObject, eventdata, handles)
% hObject    handle to menu_info_version (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_info_update_Callback(hObject, eventdata, handles)
% hObject    handle to menu_info_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_info_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_info_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_info_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_info_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function msgbox_Callback(hObject, eventdata, handles)
% hObject    handle to msgbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of msgbox as text
%        str2double(get(hObject,'String')) returns contents of msgbox as a double


% --- Executes during object creation, after setting all properties.
function msgbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to msgbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function activex1_Click(hObject, eventdata, handles)
% hObject    handle to activex1 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in button_FB.
function button_FB_Callback(hObject, eventdata, handles)
% hObject    handle to button_FB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global video_key
video_key.nowframe=max(1,video_key.nowframe-60);
set(handles.slider1,'value',max(1,video_key.nowframe-60))

% --- Executes on button press in button_PLAY.
function button_PLAY_Callback(hObject, eventdata, handles)
% hObject    handle to button_PLAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HBT video_key
set(handles.slider1,'max',round(HBT.DataInfo.VideoInfo.FrameRate*HBT.DataInfo.VideoInfo.Duration),'enable','on')
video_key.status=1;
try HBT.DataInfo.VideoInfo.Duration;
set(handles.time_end,'string',datestr(seconds(HBT.DataInfo.VideoInfo.Duration),'HH:MM:SS.FFF'))
set(handles.duration_text,'string',datestr(seconds(HBT.DataInfo.VideoInfo.Duration),'HH:MM:SS.FFF'))
set(handles.framerate_text,'string',num2str(round(HBT.DataInfo.VideoInfo.FrameRate)))
catch
   video_key.showVideo=0; 
end
try HBT.RawData;
     video_play_with_data_figfun(handles)
catch
    video_play_only_figfun(handles)
   
end

% --- Executes on button press in button_PAUSE.
function button_PAUSE_Callback(hObject, eventdata, handles)
% hObject    handle to button_PAUSE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global video_key
       video_key.status=2;

% --- Executes on button press in button_STOP.
function button_STOP_Callback(hObject, eventdata, handles)
% hObject    handle to button_STOP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global video_key
       video_key.status=3;

% --- Executes on button press in button_FF.
function button_FF_Callback(hObject, eventdata, handles)
% hObject    handle to button_FF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global video_key
video_key.nowframe=video_key.nowframe+60;
set(handles.slider1,'value',min(video_key.nowframe,get(handles.slider1,'max')))



function right_cut_Callback(hObject, eventdata, handles)
% hObject    handle to right_cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of right_cut as text
%        str2double(get(hObject,'String')) returns contents of right_cut as a double


% --- Executes during object creation, after setting all properties.
function right_cut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to right_cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
