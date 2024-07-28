function ObjectBlock(block)
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
block.NumInputPorts  = 5;
block.NumOutputPorts = 3;
block.NumDialogPrms  = 10;
%Dialog parameters
%1   SumoTs,
%2   EgoName,
%3   NumVehicles,
%4   SumoCfg,
%5   SumoIP,
%6   SumoPort,
%7   SumoGui,
%8   SumoOptions,
%9   NumTLights
%10  SensorRange

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;
NumVehicles = block.DialogPrm(3).Data;
% Override input port properties
if ~iscell(block.DialogPrm(2).Data)
    NumberOfEgos = 1;
else
    NumberOfEgos = numel(block.DialogPrm(2).Data);
end

    block.InputPort(1).Dimensions        = NumberOfEgos;    
    block.InputPort(1).DatatypeID        = 0;    % double
    block.InputPort(1).Complexity        = 'Real';
    block.InputPort(1).DirectFeedthrough = true; 

    block.InputPort(2).Dimensions        = [NumberOfEgos,2];    
    block.InputPort(2).DatatypeID        = 0;    % double
    block.InputPort(2).Complexity        = 'Real';
    block.InputPort(2).DirectFeedthrough = true; 

    block.InputPort(3).Dimensions        = NumVehicles;    
    block.InputPort(3).DatatypeID        = 0;    % double
    block.InputPort(3).Complexity        = 'Real';
    block.InputPort(3).DirectFeedthrough = true; 

    block.InputPort(4).Dimensions        = NumVehicles;    
    block.InputPort(4).DatatypeID        = 0;    % double
    block.InputPort(4).Complexity        = 'Real';
    block.InputPort(4).DirectFeedthrough = true; 

    block.InputPort(5).Dimensions        = NumVehicles;    
    block.InputPort(5).DatatypeID        = 0;    % double
    block.InputPort(5).Complexity        = 'Real';
    block.InputPort(5).DirectFeedthrough = true; 



% block.InputPort(3).Dimensions        = NumVehicles;    
% block.InputPort(3).DatatypeID        = 0;    % double
% block.InputPort(3).Complexity        = 'Real';
% block.InputPort(3).DirectFeedthrough = true;
% %n = block.DialogPrm(3).Data;

% Data of platoon
block.OutputPort(1).Dimensions  = [NumVehicles,8];
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';

% ego vehicle validation (v, x, y, s)
block.OutputPort(2).Dimensions  = [NumVehicles,4];
block.OutputPort(2).DatatypeID  = 0; % double
block.OutputPort(2).Complexity  = 'Real';
block.OutputPort(2).SamplingMode = 'Sample';


block.OutputPort(3).Dimensions  = [NumVehicles,7];
block.OutputPort(3).DatatypeID  = 0; % double
block.OutputPort(3).Complexity  = 'Real';
block.OutputPort(3).SamplingMode = 'Sample';

% % Object data[NumberOfEgos,2]
% block.OutputPort(4).Dimensions  = [NumberOfEgos,2];
% block.OutputPort(4).DatatypeID  = 0; % double
% block.OutputPort(4).Complexity  = 'Real';
% block.OutputPort(4).SamplingMode = 'Sample';
% 
% % Object data
% block.OutputPort(5).Dimensions  = NumVehicles;
% block.OutputPort(5).DatatypeID  = 0; % double
% block.OutputPort(5).Complexity  = 'Real';
% block.OutputPort(5).SamplingMode = 'Sample';

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [block.DialogPrm(1).Data, 0];

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
block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup

function SetInputPortSamplingMode(block, idx, fd)
  block.InputPort(idx).SamplingMode = fd;
  for idx=1:block.NumOutputPorts
      block.OutputPort(idx).SamplingMode = fd;
  end

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
  EgoName                  = block.DialogPrm(2).Data;
  NumVehicles              = block.DialogPrm(3).Data;
  % number of working variables
  block.NumDworks = 5;
  
  %------------------------------------------------------------------------
  % Working variable 1 : a vector of flags telling if the corresponding
  % ego vehicle gas appeared in simulation
  block.Dwork(1).Name            = 'EgoAppeared';
  block.Dwork(1).Dimensions      = numel(EgoName);
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;
  %------------------------------------------------------------------------
  % Working variable 2 : a vector of traveldistances of all ego vehicles 
  block.Dwork(2).Name            = 'EgoTravel';
  block.Dwork(2).Dimensions      = numel(EgoName);
  block.Dwork(2).DatatypeID      = 0;      % double 
  block.Dwork(2).Complexity      = 'Real'; % real
  block.Dwork(2).UsedAsDiscState = true;
    %------------------------------------------------------------------------
  % Working variable 2 : a vector of traveldistances of all ego vehicles 
  block.Dwork(3).Name            = 'JoinReq';
  block.Dwork(3).Dimensions      = NumVehicles;
  block.Dwork(3).DatatypeID      = 0;      % double 
  block.Dwork(3).Complexity      = 'Real'; % real
  block.Dwork(3).UsedAsDiscState = true;
    %------------------------------------------------------------------------
  % Working variable 2 : a vector of traveldistances of all ego vehicles 
  block.Dwork(4).Name            = 'LeaveReq';
  block.Dwork(4).Dimensions      = NumVehicles;
  block.Dwork(4).DatatypeID      = 0;      % double 
  block.Dwork(4).Complexity      = 'Real'; % real
  block.Dwork(4).UsedAsDiscState = true;
    %------------------------------------------------------------------------
  % Working variable 2 : a vector of traveldistances of all ego vehicles 
  block.Dwork(5).Name            = 'qweeasssssd';
  block.Dwork(5).Dimensions      = NumVehicles;
  block.Dwork(5).DatatypeID      = 0;      % double 
  block.Dwork(5).Complexity      = 'Real'; % real
  block.Dwork(5).UsedAsDiscState = true;
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

%   NumVehicles = block.DialogPrm(3).Data;

  % FollowerVehicle = findobj(ObjVehicles,'Tag','FollowerVehicle');

%   Follower.Signals  = zeros(NumVehicles,1);
%   Follower.IDs      = cell(NumVehicles,1);
%   Follower.IDs(:)   = {''};

  % set(FollowerVehicle,'String',Follower.IDs);
%   set(ObjVehicles,'UserData',Follower);
%end InitializeConditions


%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)
  NumberObjectsMax         = block.DialogPrm(3).Data;
  RangeObjectsMax          = block.DialogPrm(10).Data;

% global checkSignal;
global PlatoonGUI;
global FollowerGUI;
global Leader;
global Follower;
% Leader     = get(PlatoonGUI,'UserData');
% Convenience declerations ------------------------------------------------
SumoTs       = block.DialogPrm(1).Data;                % SUMO sampling time
if ~iscell(block.DialogPrm(2).Data)
    EgoName  = {block.DialogPrm(2).Data};
else
    EgoName  = block.DialogPrm(2).Data;
end
NumberOfCars = numel(EgoName);

%--------------------------------------------------------------------------
% SUMO currently (0.25) delays signals at output by one sample
% and in the first step at time = 0, no values are available.
% one call of simulation step incements by 1*dt

% read out simulation time (is always available from t=0, and it is the 
% only signal which is not delayed)
t = 0.001 * traci.simulation.getTime();
if t==0 % clear all persistant variables
   % unfortunately this is not possible in other ways safely
%    global aaa;
%    aaa = Follower;
   clear objIDs
end



% get a list of all vehicles that are arrived in SUMO now
% needed for first appearance AND object signals
listOfCarsInSimulation = traci.vehicle.getIDList();                 

% get the indizes of all EGO-vehicles that arrived in simulation now
% idxEgoCarsInSim = find( ismember( EgoName, listOfCarsInSimulation ) );
% EgoCarsInSim    = intersect( EgoName, listOfCarsInSimulation );
% get all cars but the first ego car
ObjectsInSim    = setdiff( listOfCarsInSimulation, PlatoonGUI.fig.Name  );  

% NumberObjectsMax
followerIDs = cell(NumberObjectsMax,1);
followerIDs(:) = {''};




FollowerGUI.NearVehicle.String = ObjectsInSim;

removeIdx = [];

if isa(Follower,'inf_veh')
    for idx = 1:numel(Follower)
        Follower(idx) = Follower(idx).UpdateInfo(Leader.Pos,Leader.Ang);
%         if Follower(idx).dist <= 250 & Follower(idx).sig == 10
%             Follower(idx).sig = 1;
%         end
        if Follower(idx).InPlatoon ~= 0
            desieredIdx = find(ismember(Leader.velocity.To,Follower(idx).ID));
            if ~isempty(desieredIdx)
                Follower(idx) = Follower(idx).setParameter;
                Follower(idx) = Follower(idx).SetSpeed(Leader.velocity.v(desieredIdx(1)),...
                    Leader.velocity.To{desieredIdx(1)});
                Leader.Platoon(idx) = Follower(idx);
                followerIDs(idx) = {Follower(idx).ID};
                if Follower(idx).InPlatoon == 1
                    traci.vehicle.changeLane(Follower(idx).ID,0,2);
                end
                
                switch Follower(idx).lane
                    case 0
                        traci.vehicle.changeLane(Follower(idx).ID,0,10);
                    otherwise
                        traci.vehicle.changeLane(Follower(idx).ID,1,10);
                end

                if Follower(idx).InPlatoon == 3 & Follower(idx).lane == 1
                    removeIdx(end+1) = idx;
                end
            end
        end
    end
end

if ~isempty(removeIdx)
    for idx = removeIdx
        traci.vehicle.setColor(Follower(idx).ID,Follower(idx).Color.Yellow);
    end
    Follower(removeIdx) = [];
    Leader.Platoon(removeIdx) = [];
end

% leaderSignals = block.InputPort(3).Data;
if ~isempty(Leader.signal.Type)
    for idx5 = 1:length(Leader.signal.Type)
        idx5
      switch Leader.signal.Type(idx5)
      case 0
        % nothing
        asegyy = 5848451
      case 1
        % nothing
        asdas111111 = 1111111111111111
      case 2
        % nothing
        sadefirg2222 = 2222222222222222
      case 3
          for idx = 1:numel(Follower)
              if strcmp(Follower(idx).ID,Leader.signal.To{idx5})
                  switch Follower(idx).sig
                      case 1
                          if isa(Leader.Platoon,'inf_veh') 
                              Follower(idx).sig = 0;
                              Follower(idx).InPlatoon = 2;
                              Follower(idx) = Follower(idx).setParameter;
                              Leader.Platoon(end+1) = Follower(idx);
                              %Leader.signal.To   = '';
                              %Leader.signal.Type = 0;
                              traci.vehicle.setColor(Follower(idx).ID,Follower(idx).Color.Red);
                          else
                              Follower(idx).sig = 0;
                              Follower(idx).InPlatoon = 2;
                              Follower(idx) = Follower(idx).setParameter;
                              traci.vehicle.setColor(Follower(idx).ID,Follower(idx).Color.Red);
                              Leader.Platoon = Follower(idx);
                              %Leader.signal.To   = '';
                              %Leader.signal.Type = 0;
                          end
                      case 2
                          for idx2 = 1:numel(Leader.Platoon)
                              if strcmp(Leader.Platoon(idx2).ID,Follower(idx).ID)
                                traci.vehicle.setColor(Follower(idx).ID,...
                                    Follower(idx).Color.Violet);

                                Follower(idx).sig = 0;
                                Follower(idx).InPlatoon = 3;
                                % traci.vehicle.changeLane(Follower(idx).ID,1,5);
                                % Leader.Platoon(idx2) = [];  
                                % Follower(idx) = [];
                                break;
                              end
                          end
                  end
                  break
              end
          end

      case 4
         for idx = 1:numel(Follower)
              if strcmp(Follower(idx).ID,Leader.signal.To{idx5})
                  switch Follower(idx).sig
                      case 0
                          % nothing
                      case 1
                          zxcsad = 841518
                        Follower(idx).sig = 0
                        traci.vehicle.setColor(Follower(idx).ID,Follower(idx).Color.Yellow);
                        Follower(idx) = [];
                      case 2
                        Follower(idx).sig = 0;
                        if Follower(idx).InPlatoon == 1
                            traci.vehicle.setColor(Follower(idx).ID,Follower(idx).Color.Blue);
                        elseif Follower(idx).InPlatoon == 2
                            traci.vehicle.setColor(Follower(idx).ID,Follower(idx).Color.Red);
                        end
                      case 20
                        zxcsad = 841518
                        Follower(idx).sig = 0
                        traci.vehicle.setColor(Follower(idx).ID,Follower(idx).Color.Yellow);
                        Follower(idx) = [];
                  end
                  break
              end
         end
      case 101
          hjygiugiuhlk = 1
          %Follower(idx7).InPlatoon = 1;
          traci.vehicle.changeLane(Leader.signal.To{idx5},0,2);
      case 102
          %Follower(idx7).InPlatoon = 1;
          traci.vehicle.changeLane(Leader.signal.To{idx5},1,2);
      end

    end 
end
Leader.signal.To(:)   = '';
Leader.signal.Type(:) = [];
% InPlatoon = block.InputPort(4).Data;
% v_new     = block.InputPort(5).Data;

% followerIDs = cell(NumberObjectsMax,1);
% followerIDs(find(InPlatoon)) = objIDs(find(InPlatoon));

FollowerGUI.FollowerVehicle.String(:) = {''};
FollowerGUI.FollowerVehicle.String(1) = {Leader.ID};
FollowerGUI.FollowerVehicle.String(2:numel(followerIDs)+1) = followerIDs;



% if ~isempty(find(InPlatoon))
%   idx = find(InPlatoon);
%   for m = 1:length(idx)
%     dummy = idx(m);
%     traci.vehicle.setTau      ( objIDs{dummy}, 0.2    );
%     % traci.vehicle.setSpeedMode( objIDs{dummy}, 0    );
%     traci.vehicle.setAccel    ( objIDs{dummy}, 1000 );
%     % traci.vehicle.setAccel    ( objIDs{dummy}, 1000 );
%     traci.vehicle.setDecel    ( objIDs{dummy}, 1000 );
%     traci.vehicle.slowDown    ( objIDs{dummy}, v_new(dummy),0.1);
%     traci.vehicle.changeLane  ( objIDs{dummy}, 0,10);
%     traci.vehicle.setColor    (objIDs{dummy},[0 0 255 255]);
%   end
% end

%         dist
%         velo
%         ang
%         sig        = 0;
%         lane
%         ID         = '';
%         InPlatoon  = 0;
%         findLeader = 0;
%         Nr
vehID       = cell (NumberObjectsMax,1);
vehID(:)    ={''};
DistXY      = zeros(NumberObjectsMax,2);
velocity    = zeros(NumberObjectsMax,1);
vehSig      = zeros(NumberObjectsMax,1);
vehLane     = zeros(NumberObjectsMax,1);
Length      = zeros(NumberObjectsMax,1);
errorDistXY = zeros(NumberObjectsMax,2);
errorVel    = zeros(NumberObjectsMax,1);
inPlatoon   = zeros(NumberObjectsMax,1);
CO2         = zeros(NumberObjectsMax,1);
CO          = zeros(NumberObjectsMax,1);
Fuel        = zeros(NumberObjectsMax,1);
HC          = zeros(NumberObjectsMax,1);
Noise       = zeros(NumberObjectsMax,1);
NOx         = zeros(NumberObjectsMax,1);
PMx         = zeros(NumberObjectsMax,1);
Distance    = zeros(NumberObjectsMax,1);

block.OutputPort(1).Data = zeros(block.OutputPort(1).Dimensions);
block.OutputPort(2).Data = zeros(block.OutputPort(2).Dimensions);
for idx = 1:numel(Follower)
    vehID{idx}     = Follower(idx).ID;
    DistXY(idx,:)  = Follower(idx).dist;
    Length(idx)    = Follower(idx).Length;
    velocity(idx)  = Follower(idx).velo;
    vehLane(idx)   = Follower(idx).lane;
    vehSig(idx)    = Follower(idx).sig;
    inPlatoon(idx) = Follower(idx).InPlatoon;
    Distance(idx)  = Follower(idx).Distance;
%     CO2         = Follower(idx).CO2;
%     CO          = Follower(idx).CO;
%     Fuel        = Follower(idx).Fuel;
%     HC          = Follower(idx).HC;
%     Noise       = Follower(idx).Noise;
%     NOx         = Follower(idx).NOx;
%     PMx         = Follower(idx).PMx;
end
[errorDistXY(:,1),errorDistXY(:,2),errorVel] = ...
    fcn(DistXY(:,1),DistXY(:,2),velocity,Leader.Vel,inPlatoon,NumberObjectsMax,Length);
fprintf('----------------------****************-------------\n')

persistent objIDs
if isempty(objIDs)
   objIDs   = cell(NumberObjectsMax,1);
   objIDs(:)={''};
end

objIDs( ismember(objIDs,setdiff(objIDs,vehID)) ) = {''};

% find places to insert the obects data and mark new objects
objectIndex   = zeros(numel(vehID),1);
objectNewFlag = zeros(numel(vehID),1);

for i=1:numel(vehID) % for all objects
    % look if and where the object is in the old list
    [objectExists, objectIndPos] = ismember(vehID{i},objIDs);
    if ~objectExists % if this is a new object find a place to insert
        % usually matlab finds the last possible entry --> reverse order

        [~, objectIndPos] = ismember('',objIDs);
        % set new flag for the object
        objectNewFlag(i) = 1;
        % store the new object in the list and remove this free slot
        objIDs(objectIndPos) = vehID(i);
        % asd = untitled123456;
        % set(asd,'Name',CloseByObjects{i});
        % fig.obj(i) = asd;
    end
    % store position of the object in the output signal
    objectIndex(i) = objectIndPos;
end

%-------------------------------------------------------------
% output
block.OutputPort(1).Data(objectIndex,1) = velocity;
block.OutputPort(1).Data(objectIndex,2) = DistXY(:,1);
block.OutputPort(1).Data(objectIndex,3) = DistXY(:,2);
block.OutputPort(1).Data(objectIndex,4) = vehSig;
% block.OutputPort(1).Data(objectIndex,5) = vehLane;
block.OutputPort(1).Data(objectIndex,6) = errorVel;
block.OutputPort(1).Data(objectIndex,7) = errorDistXY(:,1);
block.OutputPort(1).Data(objectIndex,8) = errorDistXY(:,2);
block.OutputPort(1).Data(objectIndex,5) = Distance;


% block.OutputPort(3).Data(objectIndex,1) = CO2;
% block.OutputPort(3).Data(objectIndex,2) = CO;
% block.OutputPort(3).Data(objectIndex,3) = Fuel;
% block.OutputPort(3).Data(objectIndex,4) = HC;
% block.OutputPort(3).Data(objectIndex,5) = Noise;
% block.OutputPort(3).Data(objectIndex,6) = NOx;
% block.OutputPort(3).Data(objectIndex,7) = PMx;

% d = block.OutputPort(1).Dimensions;
% block.OutputPort(1).Data = zeros(d(1), d(2));
% % flag (0..off, 1..active, 2..new)
%     % block.OutputPort(4).Data(1,objectIndex) = 1 + objectNewFlag;
% % dist x
%    block.OutputPort(1).Data(:,objectIndex) = [AboluteVel,DistXY(:,1),DistXY(:,2)]';
% % dist y
%     block.OutputPort(2).Data(objectIndex,2) = 0;
% 
%     block.OutputPort(4).Data(objectIndex) = AboluteVel;
% vel x
    % block.OutputPort(1).Data(objectIndex) = AboluteVel;
%     block.OutputPort(4).Data(4,objectIndex) = AboluteVel(:,1);
% % vel y
%     block.OutputPort(4).Data(5,objectIndex) = AboluteVel(:,2);
% lane
%     block.OutputPort(4).Data(6,objectIndex) = ObjectLan;
% % lateraloffset
%     % not relevant for SUMO, since all cars go on edges
%     block.OutputPort(4).Data(7,:) = zeros(1,NumberObjectsMax);
% % brake signal
%     block.OutputPort(4).Data(8,objectIndex) = ObjectSig;
% % object width
%     block.OutputPort(4).Data(9,objectIndex) = 2;    %TODO GET FROM SUMO

%     block.OutputPort(3).Data = Follower.Signals;

%end Outputs
%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)


%end Terminate

%% HELPER functions
function [outputArg1] = IDsSaving(inputArg1)

    persistent loser;
    if nargin == 1
        loser = inputArg1;
        return
    elseif nargin == 0
        outputArg1 = loser;
    end
    
    
function [edx,edy,ev] = fcn(dx,dy,v,v_leader,flags,NumberObjectsMax,Length)



edx = zeros(NumberObjectsMax,1);
edy = zeros(NumberObjectsMax,1);
ev  = zeros(NumberObjectsMax,1);


idx = find(flags);
if ~isempty(idx)
    d = sqrt(dx(idx).^2 + dy(idx).^2);
    [~,sortIdx] = sort(d);
    temp = idx(sortIdx);
    switch length(temp)
        case 1
            edx(temp) = dx(temp) + Length(temp);
            edy(temp) = dy(temp);
            ev(temp)  = v(temp) - v_leader;
        otherwise
            edx(temp(1)) = dx(temp(1)) + Length(temp(1));
            edy(temp(1)) = dy(temp(1));
            edx([temp(2:end)]) = dx([temp(2:end)]) - dx([temp(1:end-1)]) +  + Length([temp(1:end-1)]);;
            edy([temp(2:end)]) = dy([temp(2:end)]) - dy([temp(1:end-1)]);
            
            ev(temp(1)) = v(temp(1)) - v_leader;
            ev([temp(2:end)]) = v([temp(2:end)]) - v([temp(1:end-1)]);
    end
end