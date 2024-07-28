function varargout = SUMO_Vehicle(varargin)
% SUMO_Vehicle MATLAB code for SUMO_Vehicle.fig
%      SUMO_Vehicle, by itself, creates a new SUMO_Vehicle or raises the existing
%      singleton*.
%
%      H = SUMO_Vehicle returns the handle to a new SUMO_Vehicle or the handle to
%      the existing singleton*.
%
%      SUMO_Vehicle('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUMO_Vehicle.M with the given input arguments.
%
%      SUMO_Vehicle('Property','Value',...) creates a new SUMO_Vehicle or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SUMO_Vehicle_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SUMO_Vehicle_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SUMO_Vehicle

% Last Modified by GUIDE v2.5 12-Jan-2020 13:36:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SUMO_Vehicle_OpeningFcn, ...
                   'gui_OutputFcn',  @SUMO_Vehicle_OutputFcn, ...
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


% --- Executes just before SUMO_Vehicle is made visible.
function SUMO_Vehicle_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SUMO_Vehicle (see VARARGIN)

% Choose default command line output for SUMO_Vehicle
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SUMO_Vehicle wait for user response (see UIRESUME)
% uiwait(handles.SUMO_Vehicles);


% --- Outputs from this function are returned to the command line.
function varargout = SUMO_Vehicle_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in LeaderVehicle.
function NearVehicle_Callback(hObject, eventdata, handles)
% hObject    handle to LeaderVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LeaderVehicle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LeaderVehicle
set(handles.joinReq,'Enable','on');
set(handles.leaveReq,'Enable','off');
idx = get(hObject,'Value');
IDs = get(hObject,'String');
if idx > numel(IDs)
    set(hObject,'Value',0);
else
    
end

% --- Executes during object creation, after setting all properties.
function NearVehicle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LeaderVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FollowerVehicle.
function FollowerVehicle_Callback(hObject, eventdata, handles)
% hObject    handle to FollowerVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FollowerVehicle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FollowerVehicle


% --- Executes during object creation, after setting all properties.
function FollowerVehicle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FollowerVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LeaderVehicle.
function LeaderVehicle_Callback(hObject, eventdata, handles)
% hObject    handle to LeaderVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LeaderVehicle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LeaderVehicle
set(handles.joinReq,'Enable','on');
set(handles.leaveReq,'Enable','off');

% --- Executes during object creation, after setting all properties.
function LeaderVehicle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LeaderVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in joinReq.
function joinReq_Callback(hObject, eventdata, handles)
% hObject    handle to joinReq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% UD.current.IDs
% UD.current.Flag
% UD.current.Velocity.x
% UD.current.Velocity.y
% UD.current.Position.x
% UD.current.Position.y
% UD.current.Signals.From
% UD.current.Signals.Type
% UD.current.Signals.To

UD = get(handles.output,'UserData');
global checkSignal
idx = get(handles.NearVehicle,'Value');
objID = get(handles.NearVehicle,'String');
if ~isempty(objID(idx))
    temp = find(strcmp(objID(idx),UD.current.IDs));
    if ~isempty(temp)
        UD.current.Signals.From(temp) =  UD.current.IDs(temp);
        UD.current.Signals.Type(temp) = 1;
        UD.current.Signals.To(temp)   = {'ego'};
        if checkSignal == 1
            UD.current.Signals.Wait(temp) = 1;
            set(handles.output,'UserData',UD);
            return
        end
        % checkSignal = 1;
    end
end
set(handles.output,'UserData',UD);
% --- Executes on button press in leaveReq.
function leaveReq_Callback(hObject, eventdata, handles)
% hObject    handle to leaveReq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close SUMO_Vehicles.
function SUMO_Vehicles_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to SUMO_Vehicles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes during object deletion, before destroying properties.
function NearVehicle_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to LeaderVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function LeaderVehicle_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to LeaderVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
