function varargout = Streaming(varargin)
% STREAMING MATLAB code for Streaming.fig
%      STREAMING, by itself, creates a new STREAMING or raises the existing
%      singleton*.
%
%      H = STREAMING returns the handle to a new STREAMING or the handle to
%      the existing singleton*.
%
%      STREAMING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STREAMING.M with the given input arguments.
%
%      STREAMING('Property','Value',...) creates a new STREAMING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Streaming_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Streaming_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Streaming

% Last Modified by GUIDE v2.5 10-Jul-2016 23:27:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Streaming_OpeningFcn, ...
                   'gui_OutputFcn',  @Streaming_OutputFcn, ...
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

global pulseLibraryfName
global pulseLibraryPathname

global pulseLibraryIndexVectorfName
global pulseLibraryIndexPathname

global eventLibraryFileName
global eventLibraryFileNamePathname

global dataStreamingFileName
global dataStreamingPathname
% --- Executes just before Streaming is made visible.
function Streaming_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Streaming (see VARARGIN)

% Choose default command line output for Streaming
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Streaming wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Streaming_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_plf.
function pushbutton_plf_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pulseLibraryfName
global pulseLibraryPathname
[pulseLibraryfName, pulseLibraryPathname] = uigetfile('*.slf', 'Select a pulse library file (extension: slf)');
if isequal(pulseLibraryfName,0)
    display_edit='User selected Cancel';
else
    display_edit=[fullfile(pulseLibraryPathname, pulseLibraryfName)];
end
    set(handles.edit_path_plf,'string',display_edit);

% --- Executes on button press in pushbutton_plif.
function pushbutton_plif_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pulseLibraryIndexVectorfName
global pulseLibraryIndexPathname
[pulseLibraryIndexVectorfName, pulseLibraryIndexPathname] = uigetfile('*.sif', 'Select a pulse library index vector file (extension: sif)');
if isequal(pulseLibraryIndexVectorfName,0)
   display_edit='User selected Cancel';
else
   display_edit=[fullfile(pulseLibraryIndexPathname, pulseLibraryIndexVectorfName)];
end
    set(handles.edit_path_plif,'string',display_edit);
    
% --- Executes on button press in pushbutton_elf.
function pushbutton_elf_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_elf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global eventLibraryFileName
global eventLibraryFileNamePathname
[eventLibraryFileName, eventLibraryFileNamePathname] = uigetfile('*.sef', 'Select a event library file (extension: sef)');
if isequal(eventLibraryFileName,0)
   display_edit='User selected Cancel';
else
   display_edit=[fullfile(eventLibraryFileNamePathname, eventLibraryFileName)];
end
    set(handles.edit_path_elf,'string',display_edit);

function edit_path_plf_Callback(hObject, eventdata, handles)
% hObject    handle to edit_path_plf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_path_plf as text
%        str2double(get(hObject,'String')) returns contents of edit_path_plf as a double


% --- Executes during object creation, after setting all properties.
function edit_path_plf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_path_plf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_path_plif_Callback(hObject, eventdata, handles)
% hObject    handle to edit_path_plif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_path_plif as text
%        str2double(get(hObject,'String')) returns contents of edit_path_plif as a double


% --- Executes during object creation, after setting all properties.
function edit_path_plif_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_path_plif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_path_elf_Callback(hObject, eventdata, handles)
% hObject    handle to edit_path_elf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_path_elf as text
%        str2double(get(hObject,'String')) returns contents of edit_path_elf as a double


% --- Executes during object creation, after setting all properties.
function edit_path_elf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_path_elf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_save_file.
function pushbutton_save_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dataStreamingFileName
global dataStreamingPathname
[dataStreamingFileName, dataStreamingPathname] = uiputfile('*.bin',...
                       'Save file name');
if isequal(dataStreamingFileName,0) || isequal(dataStreamingPathname,0)
   display_edit='User selected Cancel';
else
   display_edit=[fullfile(dataStreamingPathname,dataStreamingFileName)];
end
    set(handles.edit_save_file,'string',display_edit);

function edit_time_window_Callback(hObject, eventdata, handles)
% hObject    handle to edit_time_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_time_window as text
%        str2double(get(hObject,'String')) returns contents of edit_time_window as a double


% --- Executes during object creation, after setting all properties.
function edit_time_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_time_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_save_file_Callback(hObject, eventdata, handles)
% hObject    handle to edit_save_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_save_file as text
%        str2double(get(hObject,'String')) returns contents of edit_save_file as a double


% --- Executes during object creation, after setting all properties.
function edit_save_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_save_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_create_data.
function pushbutton_create_data_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_create_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pulseLibraryfName
global pulseLibraryPathname

global pulseLibraryIndexVectorfName
global pulseLibraryIndexPathname

global eventLibraryFileName
global eventLibraryFileNamePathname

global dataStreamingFileName
global dataStreamingPathname

if isequal(pulseLibraryfName,0)||isequal(pulseLibraryIndexVectorfName,0)||isequal(eventLibraryFileName,0)||isequal(dataStreamingFileName,0)
   msgbox('User selected Cancel, choose file', 'Warning','warn');
else
    libraryFileName=struct('pulseLibraryfName',pulseLibraryfName,...
                   'pulseLibraryIndexVectorfName',pulseLibraryIndexVectorfName,...
                   'eventLibraryFileName',eventLibraryFileName);

    libraryPathname=struct('pulseLibraryPathname',pulseLibraryPathname,...
                       'pulseLibraryIndexPathname', pulseLibraryIndexPathname,...
                       'eventLibraryFileNamePathname',eventLibraryFileNamePathname);
                   
    TimeWindow = str2num(get(handles.edit_time_window,'string'));

    TimeWindow
    libraryPathname
    dataStreamingPathname
    libraryFileName
    dataStreamingFileName
    topFunction(TimeWindow,libraryPathname,dataStreamingPathname,libraryFileName,dataStreamingFileName);  
    msgbox('Operation Completed','Success');
end
           
