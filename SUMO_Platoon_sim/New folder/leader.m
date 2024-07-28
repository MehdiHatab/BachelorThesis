function leader(block)
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
block.NumInputPorts  = 2;
block.NumOutputPorts = 4;
block.NumDialogPrms  = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
x = block.DialogPrm(1).Data;

block.InputPort(1).Dimensions        = 1;    
block.InputPort(1).DatatypeID        = 0;    % double
block.InputPort(1).Complexity        = 'Real';
block.InputPort(1).DirectFeedthrough = true; 

block.InputPort(2).Dimensions        = 1;    
block.InputPort(2).DatatypeID        = 0;    % double
block.InputPort(2).Complexity        = 'Real';
block.InputPort(2).DirectFeedthrough = true;

% Override output port properties
block.OutputPort(1).Dimensions   = x;
block.OutputPort(1).DatatypeID   = 0; % double
block.OutputPort(1).Complexity   = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';

block.OutputPort(2).Dimensions   = x;
block.OutputPort(2).DatatypeID   = 0; % double
block.OutputPort(2).Complexity   = 'Real';
block.OutputPort(2).SamplingMode = 'Sample';

block.OutputPort(3).Dimensions   = 1;
block.OutputPort(3).DatatypeID   = 0; % double
block.OutputPort(3).Complexity   = 'Real';
block.OutputPort(3).SamplingMode = 'Sample';
% 
% block.OutputPort(4).Dimensions   = x+1;
% block.OutputPort(4).DatatypeID   = 0; % double
% block.OutputPort(4).Complexity   = 'Real';
% block.OutputPort(4).SamplingMode = 'Sample';





% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [0.5 0];

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

block.RegBlockMethod('SetInputPortSamplingMode', @SetInputPortSamplingMode);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup

function SetInputPortSamplingMode(block, idx, fd)
  block.InputPort(idx).SamplingMode = fd;
  for idx=1:block.NumOutputPorts
      block.OutputPort(idx).SamplingMode = fd;
  end

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)

t         = block.InputPort(2).Data;
numObj    = block.DialogPrm(1).Data;
velocity  = zeros(numObj,1);
e         = zeros(numObj,1);
dist_ego  = block.InputPort(1).Data;
contro_on = 0
a = [0;0];
% persistent follower_info;
% persistent text1;
% persistent accept_btn;
% persistent decline_btn;
% persistent follower_veh;


global IDsVeh;
% if t == 0
% %     clear follower_info text1 accept_btn decline_btn follower_veh
%     follower_info = figure(789);
% 
%     set(789, 'MenuBar', 'none');
%     set(789, 'ToolBar', 'none');
% 
%     text1 = uicontrol(follower_info,'Style','text','Units','normalized','Position',...
%         [0.1,0.2,0.8,0.1]);
%     accept_btn = uicontrol(follower_info,'Style','pushbutton','Units','normalized',...
%         'Position',[0.1,0.1,0.2,0.1],'String','Accept','Enable','off');
% 
%     decline_btn = uicontrol(follower_info,'Style','pushbutton','Units','normalized',...
%         'Position',[0.7,0.1,0.2,0.1],'String','Decline','Enable','off');
% 
%     follower_veh = uicontrol(follower_info,'Style','listbox','Units','normalized',...
%         'Position',[0.1,0.5,0.2,0.4]);
%     accept_btn.Callback = {@accept_btn_callback,follower_veh,text1};
% else

text1        = findobj(789,'Tag','Text');
accept_btn   = findobj(789,'Tag','Accept');
decline_btn  = findobj(789,'Tag','Decline');
follower_veh = findobj(789,'Tag','FollowerVehicle');
    
request_info = findobj(123456789,'Tag','NearVehicle');


if ~isempty(request_info.UserData)
    qweasdzxc = request_info.UserData.join_reqVeh;

    [val,idx] = find(qweasdzxc);
    if ~isempty(idx)
        text1.String = 'Vehicle "x" want to join the platoon. Do you want to accept it?';
        accept_btn.Enable = 'on';
        decline_btn.Enable = 'on';
    end
end

leader_block = 'Example_SOMU_SYNC/Leader';
ud = get_param(leader_block,'UserData');
if ~isempty(ud)
    if ud.accepted(1) == 1
    %     dist = traci.vehicle.getDistance('x');
    % %     dist = sqrt(dist(1)^2 + dist(2)^2);
    %     velocity = traci.vehicle.getSpeed('x');
    %     dist_ego = traci.vehicle.getDistance('ego');
    % %     dist_ego = sqrt(dist_ego(1)^2 + dist_ego(2)^2);
    %     velocity_ego = traci.vehicle.getSpeed('ego');
        dist = ud.dist(1);
        e = -abs(dist);
        velocity = ud.vel(1);
        contro_on = 1;
%     else
%         follower_veh.UserData = 0;
%         e = 0;
%         velocity = 0;
    end
end

block.OutputPort(1).Data = e;
block.OutputPort(2).Data = velocity;
block.OutputPort(3).Data = contro_on;
% block.OutputPort(4).Data = a;


%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate


