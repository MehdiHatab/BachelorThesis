function object(block)
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
block.NumDialogPrms  = 1;

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
NumObjects  = max(1,block.DialogPrm(1).Data);
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
join_reqVeh = zeros(NumObjects,1);
leave_reqVeh = zeros(NumObjects,1);
idVeh = qwe;
detected = zeros(NumObjects,1);

detected_veh = table(idVeh,dist,vel,join_reqVeh,leave_reqVeh);
objData = detected_veh(:,2:end).Variables;

detected(find(detected_veh.dist <= 100 & flag > 0)) = ones(length(find(detected_veh.dist...
    <= 100 & flag > 0)),1);

% obj_veh(1)
% obj_veh(2)
% obj_veh(3)
% obj_veh(4)
% obj_veh(5)
% obj_veh(6)
% obj_veh(7)
% obj_veh(8)
global IDsVeh;
persistent accepted_veh;
% persistent vehicle_info;
% persistent join_req;
% persistent leave_req;
% persistent all_vehicle;
% persistent near_vehicle;
% persistent follower_veh;

follower_veh = findobj(123456789,'Tag','FollowerVehicle');
near_vehicle = findobj(123456789,'Tag','NearVehicle'    );
all_vehicle  = findobj(123456789,'Tag','AllVehicle'     );
leave_req    = findobj(123456789,'Tag','LeaveReq'       );
join_req     = findobj(123456789,'Tag','JoinReq'        );


all_vehicle.String  = IDsVeh;
if ~isempty(find(detected))
    t
    near_vehicle.String = detected_veh.idVeh(find(detected));
    % near_vehicle.UserData = detected_veh(find(detected),:)
    set(123456789,'UserData',detected_veh(find(detected),:));
else
     near_vehicle.String = {};
     near_vehicle.UserData = [];
end



% for m = 1:length(find(flag))
%     obj_veh(m) = Follower;
%     obj_veh(m).dist = sqrt(block.InputPort(2).Data(m)^2+block.InputPort(3).Data(m)^2);
%     obj_veh(m).velocity = sqrt(block.InputPort(4).Data(m)^2+block.InputPort(5).Data(m)^2);
%     obj_veh(m).join_req = 0;
%     obj_veh(m).leave_req = 0;
%     obj_veh(m).id = qwe(m);
%     obj_veh(m).detected = 1;
% end
% 
% idx_detected_obj = find(flag);
% if exist('obj_veh')
%     if ~isempty(find(obj_veh(:).detected))
%         aaa = find(obj_veh(:).dist <= 60);
%         if ~isempty(aaa)
%             near_vehicle.String = obj_veh(aaa).id;
%         end
%     end
% end

    

% if ~isempty(idx_detected_obj) && t == 8
%     follower1 = ismember({'x'},IDsVeh(idx_detected_obj));
%     if follower1
%         traci.vehicle.setSignals('x',13);
%     end
% end

if traci.vehicle.getSignals('ego') == 12
    accepted_veh(1)  = 1;
end
accepted_veh = zeros(NumObjects,1);

block.OutputPort(1).Data = accepted_veh;


%end Outputs



%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate





