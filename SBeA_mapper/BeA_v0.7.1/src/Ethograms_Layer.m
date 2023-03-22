function varargout = Ethograms_Layer(varargin)
% ETHOGRAMS_LAYER MATLAB code for Ethograms_Layer.fig
%      ETHOGRAMS_LAYER, by itself, creates a new ETHOGRAMS_LAYER or raises the existing
%      singleton*.
%
%      H = ETHOGRAMS_LAYER returns the handle to a new ETHOGRAMS_LAYER or the handle to
%      the existing singleton*.
%
%      ETHOGRAMS_LAYER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETHOGRAMS_LAYER.M with the given input arguments.
%
%      ETHOGRAMS_LAYER('Property','Value',...) creates a new ETHOGRAMS_LAYER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Ethograms_Layer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Ethograms_Layer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Ethograms_Layer

% Last Modified by GUIDE v2.5 10-Mar-2020 14:40:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Ethograms_Layer_OpeningFcn, ...
                   'gui_OutputFcn',  @Ethograms_Layer_OutputFcn, ...
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


% --- Executes just before Ethograms_Layer is made visible.
function Ethograms_Layer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Ethograms_Layer (see VARARGIN)

% Choose default command line output for Ethograms_Layer
handles.output = hObject;
axes(handles.axes1)
imshow(ones(20,200,3))
movegui(gcf,'center');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Ethograms_Layer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Ethograms_Layer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
