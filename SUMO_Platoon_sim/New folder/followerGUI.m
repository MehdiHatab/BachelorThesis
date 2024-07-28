function followerGUI(block)
%MSFUNTMPL_BASIC A Template for a Level-2 MATLAB S-Function
%   The MATLAB S-function is written as a MATLAB function with the
%   same name as the S-function. Replace 'msfuntmpl_basic' with the 
%   name of your S-function.
%
%   It should be noted that the MATLAB S-function is very similar
%   to Level-2 C-Mex S-functions. You should be able to get more
%   information for each of the block methods by referring to the
%   documentation for C-Mex S-functions.
%
%   Copyright 2003-2010 The MathWorks, Inc.

%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
setup(block);

%endfunction

%% Function: setup ===================================================
%% Abstract:
%%   Set up the basic characteristics of the S-function block such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
%%   Required         : Yes
%%   C-Mex counterpart: mdlInitializeSizes
%%
function setup(block)

% Register number of ports
block.NumInputPorts  = 10;
block.NumOutputPorts = 1;
block.NumDialogPrms  = 2;

% input 1 flag objects
% input 2 distx objects
% input 3 disty objects
% input 4 velx objects
% input 5 vely objects
% input 6 lane objects
% input 7 lateraloffset objects
% input 8 signal objects
% input 9 width objects

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
NumberOfObjects = max(1,block.DialogPrm(1).Data);

for idx_input=1:block.NumInputPorts
    block.InputPort(idx_input).Dimensions        = NumberOfObjects;    
    block.InputPort(idx_input).DatatypeID        = 0;    % double
    block.InputPort(idx_input).Complexity        = 'Real';
    block.InputPort(idx_input).DirectFeedthrough = true; 
end

block.InputPort(10).Dimensions        = 1;    
block.InputPort(10).DatatypeID        = 0;    % double
block.InputPort(10).Complexity        = 'Real';
block.InputPort(10).DirectFeedthrough = true;

% Override output port properties
block.OutputPort(1).Dimensions   = NumberOfObjects;
block.OutputPort(1).DatatypeID   = 0; % double
block.OutputPort(1).Complexity   = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';





% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
Td = block.DialogPrm(2).Data;
block.SampleTimes = [Td 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'HasNoSimState';

%% -----------------------------------------------------------------
%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

% block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
% block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
% block.RegBlockMethod('Update', @Update);
% block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup



%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this 
%%                      is the place to do it.
%%   Required         : No
%%   C-MEX counterpart: mdlStart
%%
function Start(block)
% 'Units',           'normalized',...
% 'Position',        [0.7,0.5,0.3,0.4],...
FigureName = 'Follower Panel';
Fig = figure(...
        'Units',           'pixels',...
        'Position',        [940 316 423 417],...
        'Name',            FigureName,...
        'NumberTitle',     'on',...
        'IntegerHandle',   'off',...
        'HandleVisibility','callback',...
        'Resize',          'on',...
        'MenuBar',         'none',...
        'ToolBar',         'none');

leave_req = uicontrol(...
              'Parent',  Fig,...
              'Style',   'pushbutton',...
              'Position',[200,100,100,50],...
              'String',  'Leave', ...
              'Callback',@LeaveReqCall,...
              'Interruptible','off',...
              'BusyAction','cancel', ...
              'Tag','LeaveReq',...
              'Enable','off');
          
join_req = uicontrol(...
              'Parent',  Fig,...
              'Style',   'pushbutton',...
              'Position',[50,100,100,50],...
              'String',  'Join', ...
              'Callback',@JoinReqCall,...
              'Interruptible','off',...
              'BusyAction','cancel', ...
              'Tag','JoinReq',...
              'Enable','off');

all_vehicle = uicontrol(...
              'Parent',  Fig,...
              'Style',   'listbox',...
              'Position',[10,300,100,100],...
              'String',  'Leave', ...
              'Callback',@AllVehiclesCall,...
              'Interruptible','off',...
              'BusyAction','cancel', ...
              'Tag','AllVehicle');
          
near_vehicle = uicontrol(...
              'Parent',  Fig,...
              'Style',   'listbox',...
              'Position',[150,300,100,100],...
              'Callback',@NearVehiclesCall,...
              'Interruptible','off',...
              'BusyAction','cancel', ...
              'Tag','NearVehicle');
          
follower_veh = uicontrol(...
              'Parent',  Fig,...
              'Style',   'listbox',...
              'Position',[150+140,300,100,100],...
              'Callback',@FollowerVehiclesCall,...
              'Interruptible','off',...
              'BusyAction','cancel', ...
              'Tag','FollowerVehicle');
    

% set(join_req,'Callback',{@JoinReqCall,near_vehicle})

followerVeh.IDs = {''};
followerVeh.LeaveReq.current = [];
followerVeh.LeaveReq.previous = [];
set(follower_veh,'UserData',followerVeh);

  
FigUD.IDs       = {''};
FigUD.vel       = [];
FigUD.dist      = [];
FigUD.joinReq   = [];
FigUD.leaveReq  = [];
% FigUD.waitReq   = [];
FigUD.inPlatoon = [];


FigUD.LastStep.IDs       = {''};
FigUD.LastStep.vel       = [];
FigUD.LastStep.dist      = [];
FigUD.LastStep.joinReq   = [];
FigUD.LastStep.leaveReq  = [];
% FigUD.LastStep.waitReq   = [];
FigUD.LastStep.inPlatoon = [];

set(Fig,'UserData',FigUD);
set_param(gcbh,'UserData',Fig);
%end Start

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)
numOfObj = max(1,block.DialogPrm(1).Data);
flag         = block.InputPort(1).Data;
t            = block.InputPort(10).Data;
global qwe;
%       dist
%       velocity
%       acceleration
%       join_req
%       leave_req
%       id
dist = sqrt(block.InputPort(2).Data.^2 + block.InputPort(3).Data.^2);
vel = sqrt(block.InputPort(4).Data.^2 + block.InputPort(5).Data.^2);
join_reqVeh      = zeros(numOfObj,1);
leave_reqVeh     = zeros(numOfObj,1);
% wait_reqVeh      = zeros(numOfObj,1);
inPlatoon        = zeros(numOfObj,1);
idVeh = qwe;
detected = zeros(numOfObj,1);

% detected_veh = table(idVeh,dist,vel,join_reqVeh,leave_reqVeh);
detected_veh.ID        = idVeh;
detected_veh.dist      = dist;
detected_veh.vel       = vel;
detected_veh.joinReq   = join_reqVeh;
detected_veh.leaveReq  = leave_reqVeh;
% detected_veh.waitReq   = wait_reqVeh;
detected_veh.inPlatoon = inPlatoon;
% objData = detected_veh(:,2:end).Variables;

detected(find(detected_veh.dist <= 100 & flag > 0)) = ones(length(find(detected_veh.dist...
    <= 100 & flag > 0)),1);


fig = get_param(gcbh,'UserData');
if ~ishghandle(fig ,'figure')
    Start(block);
end
figUD = get(fig,'UserData');


global IDsVeh;

near_vehicle      = findobj(fig,'Tag','NearVehicle'     );
all_vehicle       = findobj(fig,'Tag','AllVehicle'      );





set(all_vehicle,'String',IDsVeh);


leaderBlock = 'Example_SOMU_SYNC/Leader/Level-2 MATLAB S-Function';
leaderBlockHandle = get_param(leaderBlock,'Handle');
figLeader = get_param(leaderBlockHandle,'UserData');
figUDLeader = get(figLeader,'UserData');

if ~isempty(find(detected))
    near_vehicle.String = detected_veh.ID(find(detected));
    % near_vehicle.UserData = detected_veh(find(detected),:)
    figUD.IDs       = detected_veh.ID(find(detected));
    figUD.dist      = detected_veh.dist(find(detected));
    figUD.vel       = detected_veh.vel(find(detected));
    figUD.joinReq   = detected_veh.joinReq(find(detected));
    figUD.leaveReq  = detected_veh.leaveReq(find(detected));
%     figUD.waitReq   = detected_veh.waitReq(find(detected));
    figUD.inPlatoon = detected_veh.inPlatoon(find(detected));
else
     set(near_vehicle,'String',{});
end

RequestedJoinSignalIdx = find(figUD.LastStep.joinReq);
AcceptedIDsIdx = find(figUD.LastStep.inPlatoon);
if ~isempty(RequestedJoinSignalIdx)
    RequestedIDs = figUD.LastStep.IDs(RequestedJoinSignalIdx);
    for m = 1:numel(RequestedIDs)
        idx = find(strcmp(RequestedIDs(m),figUD.IDs));
        figUD.joinReq(idx) = 1;
    end
end


follower_vehicleFromLeader  = findobj(figLeader,'Tag','FollowerVehicle' );
follower_vehicle  = findobj(fig,'Tag','FollowerVehicle' );
followerVeh = get(follower_vehicle,'UserData');
followerVeh
set(follower_vehicle,'String',follower_vehicleFromLeader.String);

followerVeh.IDs = follower_vehicle.String;

followerVeh.LeaveReq.current = zeros(numel(followerVeh.IDs),1);
idx = find(followerVeh.LeaveReq.previous);
if ~isempty(idx)
    followerVeh.LeaveReq.current(idx) = ones(idx,1);
end
followerVeh.LeaveReq.previous = followerVeh.LeaveReq.current;
set(follower_vehicle,'UserData',followerVeh);





figUD.LastStep.IDs       = figUD.IDs;
figUD.LastStep.vel       = figUD.vel;
figUD.LastStep.dist      = figUD.dist;
figUD.LastStep.joinReq   = figUD.joinReq;
figUD.LastStep.leaveReq  = figUD.leaveReq;
% figUD.LastStep.waitReq   = figUD.waitReq;
figUD.LastStep.inPlatoon = figUD.inPlatoon;

set(fig,'UserData',figUD);
set_param(gcbh,'UserData',fig);
%end Outputs


%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function JoinReqCall(Obj,events)

followerBlock = 'Example_SOMU_SYNC/Follower/Level-2 MATLAB S-Function';
followerBlockHandle = get_param(followerBlock,'Handle');  

fig = get_param(followerBlockHandle,'UserData');
figUD = get(fig,'UserData');

nearVehicle = findobj(fig,'Tag','NearVehicle');
aaa = nearVehicle.Value;
if ~isempty(aaa)
    asd = nearVehicle.String(aaa);
    if ~isempty(asd)
        idx = find(strcmp(asd,figUD.IDs));
        figUD.joinReq(idx) = 1;
        set_param(followerBlockHandle,'UserData',fig);
        set(fig,'UserData',figUD);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function LeaveReqCall(Obj,events)
    followerBlock = 'Example_SOMU_SYNC/Follower/Level-2 MATLAB S-Function';
    followerBlockHandle = get_param(followerBlock,'Handle');  
    
    fig = get_param(followerBlockHandle,'UserData');
    figUD = get(fig,'UserData');
    
    followerVehicle = findobj(fig,'Tag','FollowerVehicle');
    aaa = followerVehicle.Value;
    if ~isempty(aaa)
        followerVeh = get(followerVehicle,'UserData');
        followerVeh
        asd = followerVehicle.String(aaa);
        if ~isempty(asd)
            idx = find(strcmp(asd,followerVeh.IDs));
            followerVeh.LeaveReq.current(idx) = 1;
            set(followerVehicle,'UserData',followerVeh);
            set_param(followerBlockHandle,'UserData',fig);
            set(fig,'UserData',figUD);
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%
function AllVehiclesCall(Obj,events)
followerBlock = 'Example_SOMU_SYNC/Follower/Level-2 MATLAB S-Function';
followerBlockHandle = get_param(followerBlock,'Handle');  

fig = get_param(followerBlockHandle,'UserData');
% figUD = get(fig,'UserData');
Join    = findobj(fig,'Tag','JoinReq');
Leave   = findobj(fig,'Tag','LeaveReq');
set(Join,'Enable','off');
set(Leave,'Enable','off');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function NearVehiclesCall(Obj,events)
followerBlock = 'Example_SOMU_SYNC/Follower/Level-2 MATLAB S-Function';
followerBlockHandle = get_param(followerBlock,'Handle');  

fig = get_param(followerBlockHandle,'UserData');

if isempty(get(Obj,'Value'))
    return
end

% figUD = get(fig,'UserData');
Join    = findobj(fig,'Tag','JoinReq');
Leave   = findobj(fig,'Tag','LeaveReq');
set(Join,'Enable','on');
set(Leave,'Enable','off');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function FollowerVehiclesCall(Obj,events)
followerBlock = 'Example_SOMU_SYNC/Follower/Level-2 MATLAB S-Function';
followerBlockHandle = get_param(followerBlock,'Handle');  

fig = get_param(followerBlockHandle,'UserData');
% figUD = get(fig,'UserData');
Join    = findobj(fig,'Tag','JoinReq');
Leave   = findobj(fig,'Tag','LeaveReq');
set(Join,'Enable','off');
set(Leave,'Enable','on');