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

% Last Modified by GUIDE v2.5 06-Jan-2020 12:00:26

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
% uiwait(handles.figure1);


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


SUMOVehicles = findobj('Tag','SUMO_Vehicles');
SUMOVehiclesUD = get(SUMOVehicles,'UserData');

UD = get(handles.output,'UserData');

asdzxc = IDsSaving;
idx = find(strcmp({asdzxc}, SUMOVehiclesUD.current.IDs));

switch SUMOVehiclesUD.current.Signals.Type(idx)
case 1
    if ~isempty(find(strcmp({asdzxc}, get(handles.PlatoonVehicle,'String'))))
        return
    end

    if isempty(find(UD.current.Nr))

        % follower_list.UserData = request_info.UserData(idx,:);
        Nr = 1;
        UD.current.Nr(Nr)           = 1; 
        UD.current.IDs(Nr)          = {asdzxc};
        UD.current.Velocity.x(Nr)   = SUMOVehiclesUD.current.Velocity.x(idx);
        UD.current.Velocity.y(Nr)   = SUMOVehiclesUD.current.Velocity.y(idx);
        UD.current.Position.x(Nr)   = SUMOVehiclesUD.current.Position.x(idx);
        UD.current.Position.y(Nr)   = SUMOVehiclesUD.current.Position.y(idx);
        UD.current.Signals.From(Nr) = {'ego'}};
        UD.current.Signals.To(Nr)   = {asdzxc}
        UD.current.Signals.Type(Nr) = 3;


        SUMOVehiclesUD.current.Signals.Type(idx) = 0;
        SUMOVehiclesUD.current.Signals.From(idx) = {''};
        SUMOVehiclesUD.current.Signals.To(idx)   = {''};


        set(handles.PlatoonVehicle,'String',UD.current.IDs);


        % if ~isempty(follower_list.String)
        %     follower_list.String = [follower_list.String,asdzxc];
        % else
        %     follower_list.String = {asdzxc};
        % end

        set(handles.textMessage,'String',{''});

        checkSignal = 0;

        % set(figFollower,'UserData',figUDFollower);
        % set_param(followerBlockHandle,'UserData',figFollower);
        
        % set(figLeader,'UserData',figUDLeader);
        % set_param(leaderBlockHandle,'UserData',figLeader);
    else
        Nr = length(find(UD.current.Nr));
        UD.current.Nr(Nr+1)           = Nr+1; 
        UD.current.IDs(Nr+1)          = {asdzxc};
        UD.current.Velocity.x(Nr+1)   = SUMOVehiclesUD.current.Velocity.x(idx);
        UD.current.Velocity.y(Nr+1)   = SUMOVehiclesUD.current.Velocity.y(idx);
        UD.current.Position.x(Nr+1)   = SUMOVehiclesUD.current.Position.x(idx);
        UD.current.Position.y(Nr+1)   = SUMOVehiclesUD.current.Position.y(idx);
        UD.current.Signals.From(Nr+1) = {'ego'}};
        UD.current.Signals.To(Nr+1)   = {asdzxc}
        UD.current.Signals.Type(Nr+1) = 3;


        SUMOVehiclesUD.current.Signals.Type(idx) = 0;
        SUMOVehiclesUD.current.Signals.From(idx) = {''};
        SUMOVehiclesUD.current.Signals.To(idx)   = {''};


        set(handles.PlatoonVehicle,'String',UD.current.IDs);

        set(handles.textMessage,'String',{''});

        checkSignal = 0;
    end
case 2 %leave
    asdzxc = IDsSaving;

    idx = find(strcmp({asdzxc}, UD.current.IDs));

    asdqwe = 1:numel(UD.current.IDs);
    idx = find(asdqwe ~= idx);


    figUDLeader.Nr          = 1:length(idx); 
    UD.current.IDs          = figUDLeader.IDs(idx);
    UD.current.Velocity.x   = UD.current.Velocity.x(idx);
    UD.current.Velocity.y   = UD.current.Velocity.y(idx);
    UD.current.Position.x   = UD.current.Position.x(idx);
    UD.current.Position.y   = UD.current.Position.y(idx);
    UD.current.Signals.From = UD.current.Signals.From(idx);
    UD.current.Signals.To   = UD.current.Signals.To(idx);
    UD.current.Signals.Type = UD.current.Signals.Type(idx);
    % figUDLeader.accepted(Nr + 1) = 1;
    % figUDLeader.declined(Nr + 1) = 0;

    % idx123 = find(strcmp({asdzxc}, figUDFollower.IDs));
    % figUDFollower.leaveReq(idx123)  = 0;


    set(handles.PlatoonVehicle,'String',UD.current.IDs);

    set(handles.textMessage,'String','');


end
set(SUMOVehicles,'UserData',SUMOVehiclesUD);
set(handles.output,'UserData',UD);





% --- Executes on button press in declineReq.
function declineReq_Callback(hObject, eventdata, handles)
% hObject    handle to declineReq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles