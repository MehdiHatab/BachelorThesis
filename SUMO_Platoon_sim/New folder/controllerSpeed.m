function controllerSpeed(block)
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
block.NumInputPorts  = 3;
block.NumOutputPorts = 1;
block.NumDialogPrms  = 2;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
x = block.DialogPrm(1).Data;

block.InputPort(1).Dimensions        = 1;    
block.InputPort(1).DatatypeID        = 0;    % double
block.InputPort(1).Complexity        = 'Real';
block.InputPort(1).DirectFeedthrough = true; 

block.InputPort(2).Dimensions        = x;    
block.InputPort(2).DatatypeID        = 0;    % double
block.InputPort(2).Complexity        = 'Real';
block.InputPort(2).DirectFeedthrough = true; 

block.InputPort(3).Dimensions        = 1;    
block.InputPort(3).DatatypeID        = 0;    % double
block.InputPort(3).Complexity        = 'Real';
block.InputPort(3).DirectFeedthrough = true; 

% block.InputPort(2).Dimensions        = 1;    
% block.InputPort(2).DatatypeID        = 0;    % double
% block.InputPort(2).Complexity        = 'Real';
% block.InputPort(2).DirectFeedthrough = true;

% Override output port properties
block.OutputPort(1).Dimensions   = x;
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
control_on = block.InputPort(1).Data;
u          = block.InputPort(2).Data;
t          = block.InputPort(3).Data;

if control_on == 1
  leaderBlock = 'Example_SOMU_SYNC/Leader/Level-2 MATLAB S-Function';
  leaderBlockHandle = get_param(leaderBlock,'Handle');
  figLeader = get_param(leaderBlockHandle,'UserData');
  figUDLeader = get(figLeader,'UserData');

  followerVeh = findobj(figLeader,'Tag','FollowerVehicle');

  qwe = block.InputPort(2).Data;
  for idx = 1:numel(followerVeh.String)
    traci.vehicle.setTau      ( followerVeh.String{idx}, 0    );
    traci.vehicle.setSpeedMode( followerVeh.String{idx}, 0    );
    traci.vehicle.setAccel    ( followerVeh.String{idx}, 1000 );
    traci.vehicle.setDecel    ( followerVeh.String{idx}, 1000 );
    traci.vehicle.setSpeed    ( followerVeh.String{idx}, qwe(idx));
    traci.vehicle.changeLane  ( followerVeh.String{idx}, 0,t);
  end
end
block.OutputPort(1).Data = block.InputPort(2).Data;


%block.OutputPort(1).Data = block.Dwork(1).Data + block.InputPort(1).Data;

%end Outputs


%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate

