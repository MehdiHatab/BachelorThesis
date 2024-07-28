function varargout = platoon(varargin)
% PLATOON MATLAB code for platoon.fig
%      PLATOON, by itself, creates a new PLATOON or raises the existing
%      singleton*.
%
%      H = PLATOON returns the handle to a new PLATOON or the handle to
%      the existing singleton*.
%
%      PLATOON('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLATOON.M with the given input arguments.
%
%      PLATOON('Property','Value',...) creates a new PLATOON or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before platoon_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to platoon_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help platoon

% Last Modified by GUIDE v2.5 12-Feb-2020 19:03:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @platoon_OpeningFcn, ...
                   'gui_OutputFcn',  @platoon_OutputFcn, ...
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


% --- Executes just before platoon is made visible.
function platoon_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to platoon (see VARARGIN)

% Choose default command line output for platoon
handles.output = hObject;
% handles.follower = guidata(findobj('Name','SUMO_Vehicles'));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes platoon wait for user response (see UIRESUME)
% uiwait(handles.Platoon);


% --- Outputs from this function are returned to the command line.
function varargout = platoon_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in PlatoonVehicle.
function PlatoonVehicle_Callback(hObject, eventdata, handles)
% hObject    handle to PlatoonVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PlatoonVehicle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PlatoonVehicle


% --- Executes during object creation, after setting all properties.
function PlatoonVehicle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlatoonVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in acceptReq.
function acceptReq_Callback(hObject, eventdata, handles)
% hObject    handle to acceptReq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global checkSignal;
textMessageUD = get(handles.textMessage,'UserData');


UD = get(handles.output,'UserData');



switch textMessageUD.signal
case 0
    %nothing
case 1
    UD.IDs(textMessageUD.idx)       = {textMessageUD.IDs};
    UD.Signals(textMessageUD.idx)   = 3;
    UD.InPlatoon(textMessageUD.idx) = 1;
    
    set(handles.PlatoonVehicle,'String',UD.IDs);
    textMessageUD.IDs        = '';
    textMessageUD.idx        = 0;
    textMessageUD.signal     = 0;
    set(handles.textMessage,'String','');
    set(handles.textMessage,'UserData',textMessageUD);
    set(handles.output,'UserData',UD);
    checkSignal = 0;
    set(handles.acceptReq ,'Enable','off');
    set(handles.declineReq,'Enable','off');
case 2
    UD.IDs(textMessageUD.idx)       = {''};
    UD.Signals(textMessageUD.idx)   = 3;
    UD.InPlatoon(textMessageUD.idx) = 0;

    
    
    set(handles.PlatoonVehicle,'String',UD.IDs);

    textMessageUD.IDs        = '';
    textMessageUD.idx        = 0;
    textMessageUD.signal     = 0;

    set(handles.textMessage,'String','');
    set(handles.textMessage,'UserData',textMessageUD);
    set(handles.output,'UserData',UD);

    checkSignal = 0;

    set(handles.acceptReq ,'Enable','off');
    set(handles.declineReq,'Enable','off');
end






% --- Executes on button press in declineReq.
function declineReq_Callback(hObject, eventdata, handles)
% hObject    handle to declineReq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global checkSignal;
textMessageUD = get(handles.textMessage,'UserData');


UD = get(handles.output,'UserData');



switch textMessageUD.signal
case 0
    %nothing
case 1
    % UD.IDs(textMessageUD.idx)       = {textMessageUD.IDs};
    UD.Signals(textMessageUD.idx)   = 4;
    % UD.InPlatoon(textMessageUD.idx) = 1;
    
    % set(handles.PlatoonVehicle,'String',UD.IDs);
    textMessageUD.IDs        = '';
    textMessageUD.idx        = 0;
    textMessageUD.signal     = 0;

    set(handles.textMessage,'String','');
    set(handles.textMessage,'UserData',textMessageUD);
    set(handles.output,'UserData',UD);

    checkSignal = 0;

    set(handles.acceptReq ,'Enable','off');
    set(handles.declineReq,'Enable','off');
case 2
    % UD.IDs(textMessageUD.idx)       = {textMessageUD.IDs};
    UD.Signals(textMessageUD.idx)   = 4;
    % UD.InPlatoon(textMessageUD.idx) = 0;
    
    % set(handles.PlatoonVehicle,'String',UD.IDs);

    textMessageUD.IDs        = '';
    textMessageUD.idx        = 0;
    textMessageUD.signal     = 0;

    set(handles.textMessage,'String','');
    set(handles.textMessage,'UserData',textMessageUD);
    set(handles.output,'UserData',UD);

    checkSignal = 0;

    set(handles.acceptReq ,'Enable','off');
    set(handles.declineReq,'Enable','off');
end
