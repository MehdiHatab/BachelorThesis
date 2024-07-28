function leader_veh(block)
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
block.NumInputPorts  = 1;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).Dimensions        = 1;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = true;

% Override output port properties
block.OutputPort(1).Dimensions       = 1;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';

% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [0 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

%% -----------------------------------------------------------------
%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
block.NumDworks = 2;
  
  block.Dwork(1).Name            = 'x1';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;

  block.Dwork(2).Name            = 'x2';
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;      % double
  block.Dwork(2).Complexity      = 'Real'; % real
  block.Dwork(2).UsedAsDiscState = true;


%%
%% InitializeConditions:
%%   Functionality    : Called at the start of simulation and if it is 
%%                      present in an enabled subsystem configured to reset 
%%                      states, it will be called when the enabled subsystem
%%                      restarts execution to reset the states.
%%   Required         : No
%%   C-MEX counterpart: mdlInitializeConditions
%%
function InitializeConditions(block)

%end InitializeConditions


%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this 
%%                      is the place to do it.
%%   Required         : No
%%   C-MEX counterpart: mdlStart
%%
function Start(block)

block.Dwork(1).Data = 0;
block.Dwork(2).Data = 0;

%end Start

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)
% v_leader    = block.InputPort(1).Data;
% vx_follower = block.InputPort(6).Data;
% vy_follower = block.InputPort(7).Data;
% dx_follower = block.InputPort(4).Data;
% dy_follower = block.InputPort(5).Data;
 t           = block.InputPort(1).Data;



% if t == 0
%     global aaa;
%     %untitled2
% end
% aaa.dist
% v_follower = sqrt(vx_follower.^2 + vy_follower.^2);
% d_follower = -sqrt(dx_follower.^2 + dy_follower.^2);


% s0 = block.Dwork(1).Data;
% if t > 1 & t < 100
%     traci.vehicle.setAccel    ( 'x', 5 );
%     traci.vehicle.setDecel    ( 'x', 7 );
%     traci.vehicle.slowDown('x',30,10);
% end

% if t >= 1.5 
%     traci.vehicle.setAccel    ( 'x', 1000 );
%     traci.vehicle.setTau      ( 'x', 5);
%     traci.vehicle.setSpeedMode( 'x', 0  );
%     traci.vehicle.setDecel    ( 'x', 1000 );
%     traci.vehicle.slowDown('x',20,8);
% end
% if t >= 10
%     %traci.vehicle.setSignals('x', 1);
%     traci.vehicle.addSubscriptionFilterLCManeuver(-1)
%     traci.vehicle.subscribe('ego');
%     traci.vehicle.subscribeLeader('ego',100,1,500);
% end
% if t >= 10
%     % kp = 1/100;
%     % kd = kp*1/3*150;
%    % traci.vehicle.setSignals('x', 9);
%     kp = 0.21039;
%     kd = 3.4668;
%     [u,ek] = controller(s0,d_follower,0,0,kp,kd,0.5);
%     if abs(ek) < 0.1
%         traci.vehicle.setColor    ( 'x',[0 0 255 255]);
%     end
% 
%     traci.vehicle.changeLane  ( 'x', 0,t);
%     %traci.vehicle.setTau      ( 'x', 0);
%     %traci.vehicle.setSpeedMode( 'x', 0  );
%     traci.vehicle.setAccel    ( 'x', 2  );
%     traci.vehicle.setDecel    ( 'x', 5  );
%     v = u*0.5 + v_follower;
%     traci.vehicle.slowDown('x',v,8);
%     % traci.vehicle.setSpeed('x',v);
% end

% block.Dwork(1).Data = d_follower;
% block.Dwork(2).Data = v_follower;
block.OutputPort(1).Data = t;

%end Outputs

%%
%% Derivatives:
%%   Functionality    : Called to update derivatives of
%%                      continuous states during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlDerivatives
%%
function Derivatives(block)

%end Derivatives

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate

function [u,ek] = controller(s0,s1,sL0,sL1,kp,kd,SumoTs)
ek  = -14 - (s1 - sL1);
ek1 = -14 - (s0 - sL0);
u = kp*ek + kd*(ek-ek1)/SumoTs;
if u >= 2
    u = 2;
elseif u <= -4
    u = -4;
end
