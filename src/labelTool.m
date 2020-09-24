function varargout = labelTool(varargin)
% LABELTOOL MATLAB code for labelTool.fig
%      LABELTOOL, by itself, creates a new LABELTOOL or raises the existing
%      singleton*.
%
%      H = LABELTOOL returns the handle to a new LABELTOOL or the handle to
%      the existing singleton*.
%
%      LABELTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABELTOOL.M with the given input arguments.
%
%      LABELTOOL('Property','Value',...) creates a new LABELTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before labelTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to labelTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help labelTool

% Last Modified by GUIDE v2.5 16-Aug-2020 22:58:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @labelTool_OpeningFcn, ...
                   'gui_OutputFcn',  @labelTool_OutputFcn, ...
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


% --- Executes just before labelTool is made visible.
function labelTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to labelTool (see VARARGIN)

handles.rawFolderPath = 'trainDataset/';
handles.freeFolderPath = 'labeledDataset/0/';
handles.trapFolderPath = 'labeledDataset/1/';

% Choose default command line output for labelTool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes labelTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = labelTool_OutputFcn(hObject, eventdata, handles) 
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
filename = [handles.rawFolderPath num2str(handles.imgIndex) '.png'];
set(handles.text3, 'String', filename);
axes(handles.axes1);
imshow(filename);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
num_image = str2double(get(hObject, 'String'));
handles.imgIndex = num_image;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
% label free
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% move current picture into another folder
filename = [handles.rawFolderPath num2str(handles.imgIndex) '.png'];
result = movefile(filename, handles.freeFolderPath);
if result == true
    set(handles.text5, 'String', [filename 'MOVED']);
else
    set(handles.text5, 'String', ['MOVE FAILED']);    
end
% show next picture
handles.imgIndex = handles.imgIndex + 1;
filename = [handles.rawFolderPath num2str(handles.imgIndex) '.png'];
set(handles.text3, 'String', filename);
axes(handles.axes1);
imshow(filename);
guidata(hObject, handles);


% --- Executes on button press in pushbutton5.
% label trap
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = [handles.rawFolderPath num2str(handles.imgIndex) '.png'];
result = movefile(filename, handles.trapFolderPath);
if result == true
    set(handles.text5, 'String', [filename 'MOVED']);
else
    set(handles.text5, 'String', ['MOVE FAILED']);    
end
% show next picture
handles.imgIndex = handles.imgIndex + 1;
filename = [handles.rawFolderPath num2str(handles.imgIndex) '.png'];
set(handles.text3, 'String', filename);
axes(handles.axes1);
imshow(filename);
guidata(hObject, handles);
