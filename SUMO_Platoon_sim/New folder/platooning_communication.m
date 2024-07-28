function varargout = platooning_communication(varargin)
% PLATOONING_COMMUNICATION MATLAB code for platooning_communication.fig
%      PLATOONING_COMMUNICATION, by itself, creates a new PLATOONING_COMMUNICATION or raises the existing
%      singleton*.
%
%      H = PLATOONING_COMMUNICATION returns the handle to a new PLATOONING_COMMUNICATION or the handle to
%      the existing singleton*.
%
%      PLATOONING_COMMUNICATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLATOONING_COMMUNICATION.M with the given input arguments.
%
%      PLATOONING_COMMUNICATION('Property','Value',...) creates a new PLATOONING_COMMUNICATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before platooning_communication_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to platooning_communication_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help platooning_communication

% Last Modified by GUIDE v2.5 15-Dec-2019 18:43:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @platooning_communication_OpeningFcn, ...
                   'gui_OutputFcn',  @platooning_communication_OutputFcn, ...
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


% --- Executes just before platooning_communication is made visible.
function platooning_communication_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to platooning_communication (see VARARGIN)

% Choose default command line output for platooning_communication
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes platooning_communication wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = platooning_communication_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in JoinReq.
function JoinReq_Callback(hObject, eventdata, handles)
% hObject    handle to JoinReq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
qwe = get(handles.NearVehicle,'Value');
if ~isempty(qwe)
    asd = handles.NearVehicle.String(qwe);
    aaa = handles.NearVehicle.UserData;
    if ~isempty(asd)
        aaa.join_reqVeh(qwe) = 1;
        aaa
    end
end

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


% --- Executes on selection change in FollowerVehicle.
function FollowerVehicle_Callback(hObject, eventdata, handles)
% hObject    handle to FollowerVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FollowerVehicle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FollowerVehicle
set(handles.JoinReq,'Enable','off')
set(handles.LeaveReq,'Enable','on')

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


% --- Executes on selection change in AllVehicle.
function AllVehicle_Callback(hObject, eventdata, handles)
% hObject    handle to AllVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AllVehicle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AllVehicle
set(handles.JoinReq,'Enable','off')
set(handles.LeaveReq,'Enable','off')

% --- Executes during object creation, after setting all properties.
function AllVehicle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AllVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in NearVehicle.
function NearVehicle_Callback(hObject, eventdata, handles)
% hObject    handle to NearVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NearVehicle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NearVehicle
set(handles.JoinReq,'Enable','on')
set(handles.LeaveReq,'Enable','off')

% --- Executes during object creation, after setting all properties.
function NearVehicle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NearVehicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LeaveReq.
function LeaveReq_Callback(hObject, eventdata, handles)
% hObject    handle to LeaveReq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
