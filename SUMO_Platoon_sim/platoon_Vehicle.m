function varargout = platoon_Vehicle(varargin)
% PLATOON_VEHICLE MATLAB code for platoon_Vehicle.fig
%      PLATOON_VEHICLE, by itself, creates a new PLATOON_VEHICLE or raises the existing
%      singleton*.
%
%      H = PLATOON_VEHICLE returns the handle to a new PLATOON_VEHICLE or the handle to
%      the existing singleton*.
%
%      PLATOON_VEHICLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLATOON_VEHICLE.M with the given input arguments.
%
%      PLATOON_VEHICLE('Property','Value',...) creates a new PLATOON_VEHICLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before platoon_Vehicle_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to platoon_Vehicle_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help platoon_Vehicle

% Last Modified by GUIDE v2.5 17-Feb-2020 11:56:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @platoon_Vehicle_OpeningFcn, ...
                   'gui_OutputFcn',  @platoon_Vehicle_OutputFcn, ...
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


% --- Executes just before platoon_Vehicle is made visible.
function platoon_Vehicle_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to platoon_Vehicle (see VARARGIN)

% Choose default command line output for platoon_Vehicle
handles.output = hObject;
% handles.follower = guidata(findobj('Name','SUMO_Vehicles'));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes platoon_Vehicle wait for user response (see UIRESUME)
% uiwait(handles.platoon_vehicle);


% --- Outputs from this function are returned to the command line.
function varargout = platoon_Vehicle_OutputFcn(hObject, eventdata, handles) 
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
PlatoonGUI     = findobj('Tag','Platoon');
SUMOVehicleGUI     = findobj('Tag','SUMO_Vehicles');
FollowerUD   = get(SUMOVehicleGUI,'UserData');
% Leader = get(PlatoonGUI,'UserData');
global Leader;
% textMessageUD = get(handles.textMessage,'UserData');
% 
% 
% UD = get(handles.output,'UserData');
asd = cell(numel(Leader.Platoon),1);
asd(:) = {''};

for zxc = 1:numel(Leader.Platoon)
    asd(zxc) = {Leader.Platoon(zxc).ID};
end

for m = 1:numel(FollowerUD)
    if strcmp(FollowerUD(m).ID,Leader.Follower.To)
        idx = m;
        break
    end
end

if ismember(Leader.Follower.To,asd) && Leader.Follower.Type ~= 2
    Leader = Leader.getSignal('',0);

    set(handles.textMessage,'String','');
%     set(handles.textMessage,'UserData',textMessageUD);
%     set(handles.output,'UserData',UD);
    checkSignal = 0;
    set(handles.acceptReq ,'Enable','off');
    set(handles.declineReq,'Enable','off');
    return
end

switch Leader.Follower.Type
case 0
    %nothing
case 1
    Leader = Leader.sendSignal(Leader.Follower.To,3);
%     UD.IDs(textMessageUD.idx)       = {textMessageUD.IDs};
%     UD.Signals(textMessageUD.idx)   = 3;
%     UD.InPlatoon(textMessageUD.idx) = 1;
    
%     set(handles.PlatoonVehicle,'String',UD.IDs);
%     textMessageUD.IDs        = '';
%     textMessageUD.idx        = 0;
%     textMessageUD.signal     = 0;
    Leader = Leader.getSignal('',0);
    zxc3  = 5
    set(handles.textMessage,'String','');
%     set(handles.textMessage,'UserData',textMessageUD);
%     set(handles.output,'UserData',UD);
    checkSignal = 0;
    set(handles.acceptReq ,'Enable','off');
    set(handles.declineReq,'Enable','off');
case 2
    Leader = Leader.sendSignal(Leader.Follower.To,3);
%     UD.IDs(textMessageUD.idx)       = {''};
%     UD.Signals(textMessageUD.idx)   = 3;
%     UD.InPlatoon(textMessageUD.idx) = 0;

    
    
%     set(handles.PlatoonVehicle,'String',UD.IDs);
% 
%     textMessageUD.IDs        = '';
%     textMessageUD.idx        = 0;
%     textMessageUD.signal     = 0;
    Leader = Leader.getSignal('',0);

    set(handles.textMessage,'String','');
%     set(handles.textMessage,'UserData',textMessageUD);
%     set(handles.output,'UserData',UD);
    zxc4  = 5
    checkSignal = 0;

    set(handles.acceptReq ,'Enable','off');
    set(handles.declineReq,'Enable','off');
case 20
    tempID = Leader.ID;
    Leader.ID = FollowerUD(idx).ID;
    Leader = Leader.update;
    FollowerUD(idx) = [];
    FollowerUD(end+1) = inf_veh(tempID,Leader.Pos,Leader.Ang);
    FollowerUD(end).InPlatoon = 1;
    
    Leader.Platoon(end+1) = FollowerUD(end);
    Leader = Leader.getSignal('',0);
    Leader.camera;
    loser = 5
    set(PlatoonGUI,'Name',Leader.ID);

    set(handles.textMessage,'String','');
%     set(handles.textMessage,'UserData',textMessageUD);
%     set(handles.output,'UserData',UD);

    checkSignal = 0;

    set(handles.acceptReq ,'Enable','off');
    set(handles.declineReq,'Enable','off');    
end
set(SUMOVehicleGUI,'UserData',FollowerUD);
set(PlatoonGUI,'UserData',Leader);






% --- Executes on button press in declineReq.
function declineReq_Callback(hObject, eventdata, handles)
% hObject    handle to declineReq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global checkSignal;
PlatoonGUI     = findobj('Tag','Platoon');
SUMOVehicleGUI     = findobj('Tag','SUMO_Vehicles');
FollowerUD   = get(SUMOVehicleGUI,'UserData');

global Leader;

% 
% % 
% % UD = get(handles.output,'UserData');
% asd = cell(numel(Leader.Platoon),1);
% asd(:) = {''};
% 
% for zxc = 1:numel(Leader.Platoon)
%     asd(zxc) = {Leader.Platoon(zxc).ID};
% end

for m = 1:numel(FollowerUD)
    if strcmp(FollowerUD(m).ID,Leader.Follower.To)
        idx = m;
        break
    end
end

% if ismember(Leader.Follower.To,asd)
%     Leader = Leader.getSignal('',0);
% 
%     set(handles.textMessage,'String','');
%     checkSignal = 0;
%     set(handles.acceptReq ,'Enable','off');
%     set(handles.declineReq,'Enable','off');
%     return
% end

switch Leader.Follower.Type
case 0
    %nothing
case 1
    Leader = Leader.sendSignal(Leader.Follower.To,4);

    Leader = Leader.getSignal('',0);

    set(handles.textMessage,'String','');
    zxc1  = 5
    checkSignal = 0;
    set(handles.acceptReq ,'Enable','off');
    set(handles.declineReq,'Enable','off');
case 2
    Leader = Leader.sendSignal(Leader.Follower.To,4);

    Leader = Leader.getSignal('',0);
    zxc2  = 5
    set(handles.textMessage,'String','');


    checkSignal = 0;

    set(handles.acceptReq ,'Enable','off');
    set(handles.declineReq,'Enable','off');
case 20
    tempID = Leader.ID;
    Leader.ID = FollowerUD(idx).ID;
    Leader = Leader.update;
    FollowerUD(idx) = [];
    FollowerUD(end+1) = inf_veh(tempID,Leader.Pos,Leader.Ang);
    FollowerUD(end).InPlatoon = 1;
    
    Leader.Platoon(end+1) = FollowerUD(end);
    Leader = Leader.getSignal('',0);
    Leader.camera;
    loser = 5
    set(PlatoonGUI,'Name',Leader.ID);

    set(handles.textMessage,'String','');
%     set(handles.textMessage,'UserData',textMessageUD);
%     set(handles.output,'UserData',UD);

    checkSignal = 0;

    set(handles.acceptReq ,'Enable','off');
    set(handles.declineReq,'Enable','off');    
end

set(SUMOVehicleGUI,'UserData',FollowerUD);
set(PlatoonGUI,'UserData',Leader);

