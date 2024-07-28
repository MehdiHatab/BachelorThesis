function varargout = untitled123456(varargin)
% UNTITLED123456 MATLAB code for untitled123456.fig
%      UNTITLED123456, by itself, creates a new UNTITLED123456 or raises the existing
%      singleton*.
%
%      H = UNTITLED123456 returns the handle to a new UNTITLED123456 or the handle to
%      the existing singleton*.
%
%      UNTITLED123456('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED123456.M with the given input arguments.
%
%      UNTITLED123456('Property','Value',...) creates a new UNTITLED123456 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled123456_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled123456_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled123456

% Last Modified by GUIDE v2.5 12-Jan-2020 14:07:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled123456_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled123456_OutputFcn, ...
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


% --- Executes just before untitled123456 is made visible.
function untitled123456_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled123456 (see VARARGIN)

sz = [1, 5];
varNames = {'IDs','Velocity','Position','Signals','Flag'};
varTypes = {'cell','table','table','table','double'};

SUMOVehicleUD = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

SUMOVehicleUD.Velocity = table('Size',[1, 2],...
  'VariableTypes',{'double','double'},...
  'VariableNames',{'x','y'});

SUMOVehicleUD.Position = table('Size',[1, 2],...
  'VariableTypes',{'double','double'},...
  'VariableNames',{'x','y'});

SUMOVehicleUD.Signals = table('Size',[1, 3],...
'VariableTypes',{'cell','cell','double'},...
'VariableNames',{'From','To','Type'});

vehiclesData.current  = SUMOVehicleUD;
vehiclesData.previous = SUMOVehicleUD;

set(hObject,'UserData',vehiclesData);

% Choose default command line output for untitled123456
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled123456 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled123456_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
