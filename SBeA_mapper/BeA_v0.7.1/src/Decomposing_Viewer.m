function varargout = Decomposing_Viewer(varargin)
% DECOMPOSING_VIEWER MATLAB code for Decomposing_Viewer.fig
%      DECOMPOSING_VIEWER, by itself, creates a new DECOMPOSING_VIEWER or raises the existing
%      singleton*.
%
%      H = DECOMPOSING_VIEWER returns the handle to a new DECOMPOSING_VIEWER or the handle to
%      the existing singleton*.
%
%      DECOMPOSING_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DECOMPOSING_VIEWER.M with the given input arguments.
%
%      DECOMPOSING_VIEWER('Property','Value',...) creates a new DECOMPOSING_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Decomposing_Viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Decomposing_Viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Decomposing_Viewer

% Last Modified by GUIDE v2.5 10-Mar-2020 14:54:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Decomposing_Viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @Decomposing_Viewer_OutputFcn, ...
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


% --- Executes just before Decomposing_Viewer is made visible.
function Decomposing_Viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Decomposing_Viewer (see VARARGIN)

% Choose default command line output for Decomposing_Viewer
handles.output = hObject;
movegui(gcf,'center');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Decomposing_Viewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Decomposing_Viewer_OutputFcn(hObject, eventdata, handles) 
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


% --------------------------------------------------------------------
function menu_file_imvideo_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_imvideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --------------------------------------------------------------------
function menu_file_exits_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_exits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf)

% --------------------------------------------------------------------
function menu_file_imdata_deep_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_imdata_deep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
artfical_correction

% --------------------------------------------------------------------
function menu_preprocess_smooth_Callback(hObject, eventdata, handles)
% hObject    handle to menu_preprocess_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Smoothing

% --------------------------------------------------------------------
function menu_preprocess_cut_Callback(hObject, eventdata, handles)
% hObject    handle to menu_preprocess_cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Cut_Data

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


% --------------------------------------------------------------------
function menu_tools_plotVM_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools_plotVM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_tools_plotE_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools_plotE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_tools_DW_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools_DW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --------------------------------------------------------------------
function menu_tools_ba_el_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools_ba_el (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
