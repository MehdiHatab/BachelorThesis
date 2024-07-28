function LeaderBlock(block)
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
block.NumOutputPorts = 8;
block.NumDialogPrms  = 12;
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

% Override input port properties
if ~iscell(block.DialogPrm(2).Data)
    NumberOfEgos = 1;
else
    NumberOfEgos = numel(block.DialogPrm(2).Data);
end
for idx_input=1:2
    block.InputPort(idx_input).Dimensions        = NumberOfEgos;    
    block.InputPort(idx_input).DatatypeID        = 0;    % double
    block.InputPort(idx_input).Complexity        = 'Real';
    block.InputPort(idx_input).DirectFeedthrough = true; 
end
NumVehicles = block.DialogPrm(3).Data;

block.InputPort(3).Dimensions        = NumVehicles;    
block.InputPort(3).DatatypeID        = 0;    % double
block.InputPort(3).Complexity        = 'Real';
block.InputPort(3).DirectFeedthrough = true;

block.InputPort(4).Dimensions        = [3,NumVehicles];    
block.InputPort(4).DatatypeID        = 0;    % double
block.InputPort(4).Complexity        = 'Real';
block.InputPort(4).DirectFeedthrough = true;

block.InputPort(5).Dimensions        = NumberOfEgos;    
block.InputPort(5).DatatypeID        = 0;    % double
block.InputPort(5).Complexity        = 'Real';
block.InputPort(5).DirectFeedthrough = true; 
%n = block.DialogPrm(3).Data;

% sumo time
block.OutputPort(1).Dimensions  = NumberOfEgos;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';

% ego vehicle validation (v, x, y, s)
block.OutputPort(2).Dimensions  = NumberOfEgos;
block.OutputPort(2).DatatypeID  = 0; % double
block.OutputPort(2).Complexity  = 'Real';
block.OutputPort(2).SamplingMode = 'Sample';

% GPS
block.OutputPort(3).Dimensions  = NumberOfEgos;
block.OutputPort(3).DatatypeID  = 0; % double
block.OutputPort(3).Complexity  = 'Real';
block.OutputPort(3).SamplingMode = 'Sample';

% Object data[NumberOfEgos,2]
block.OutputPort(4).Dimensions  = [NumberOfEgos,2];
block.OutputPort(4).DatatypeID  = 0; % double
block.OutputPort(4).Complexity  = 'Real';
block.OutputPort(4).SamplingMode = 'Sample';

% Object data
block.OutputPort(5).Dimensions  = NumVehicles;
block.OutputPort(5).DatatypeID  = 0; % double
block.OutputPort(5).Complexity  = 'Real';
block.OutputPort(5).SamplingMode = 'Sample';

% Vehicles that are in Platoon 
block.OutputPort(6).Dimensions  = NumVehicles;
block.OutputPort(6).DatatypeID  = 0; % double
block.OutputPort(6).Complexity  = 'Real';
block.OutputPort(6).SamplingMode = 'Sample';

% controller
block.OutputPort(7).Dimensions  = 1;
block.OutputPort(7).DatatypeID  = 0; % double
block.OutputPort(7).Complexity  = 'Real';
block.OutputPort(7).SamplingMode = 'Sample';


% Vehicles that are in Platoon 
block.OutputPort(8).Dimensions  = NumVehicles;
block.OutputPort(8).DatatypeID  = 0; % double
block.OutputPort(8).Complexity  = 'Real';
block.OutputPort(8).SamplingMode = 'Sample';
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
  block.Dwork(3).Dimensions      = 1;
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
  % open connection to Sumo
%   close all
global Leader;
global Follower;

Leader = [];
Follower = [];

clear Leader Follower PlatoonGUI FollowerGUI
close all

    global checkSignal;
    global PlatoonGUI;
    global FollowerGUI;
    
    
    PlatoonGUI   = LeaderGUI_ver2;
    FollowerGUI  = FollowerGUI_ver2;
    
    
    checkSignal  = 0;
    NumVehicles  = block.DialogPrm(3).Data;

    
    if ~iscell(block.DialogPrm(2).Data)
        EgoName  = {block.DialogPrm(2).Data};
    else
        EgoName  = block.DialogPrm(2).Data;
    end
    
    PlatoonGUI.fig.Name = EgoName{1};
    PlatoonGUI.TextMessage.String = '';
    PlatoonGUI.FollowerVehicle.String = {''};
    FollowerGUI.NearVehicle.String = {''};
    FollowerGUI.FollowerVehicle.String = {''};

   
%     UD.IDs       = cell(NumVehicles,1);
%     UD.IDs(:)    = {''};
%     UD.InPlatoon = zeros(NumVehicles,1);
%     UD.Signals   = zeros(NumVehicles,1);
% 
%     set(PlatoonGUI,'UserData',UD);

  SumoParam.dt            = block.DialogPrm(1).Data;
  SumoParam.scenarioPath  = block.DialogPrm(4).Data;
  SumoParam.ip            = block.DialogPrm(5).Data;
  SumoParam.port          = block.DialogPrm(6).Data;
  SumoParam.gui           = block.DialogPrm(7).Data;
  SumoParam.sumoOptions   = block.DialogPrm(8).Data;
  
  % initialize ego visible indicator
  block.Dwork(1).Data = 0*block.Dwork(1).Data; % init appearFlag
  block.Dwork(2).Data = 0*block.Dwork(2).Data; % init traveldist
  block.Dwork(3).Data = 0*block.Dwork(3).Data;
  
  try
    initSUMO( SumoParam );
  catch err %#ok<NASGU>
    terminateSUMO();
  end

%end InitializeConditions


%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)

RFGColor = color;
% Convenience declerations ------------------------------------------------
SumoTs       = block.DialogPrm(1).Data;                % SUMO sampling time
if ~iscell(block.DialogPrm(2).Data)
    EgoName  = {block.DialogPrm(2).Data};
else
    EgoName  = block.DialogPrm(2).Data;
end
SumoGui      = block.DialogPrm(7).Data;
NumberOfCars = numel(EgoName);
NumVehicles = block.DialogPrm(3).Data;

global checkSignal;
global PlatoonGUI;
% global FollowerGUI;
global Leader;
global Follower;


% 
% Leader = get(PlatoonGUI,'UserData');

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

   clear objIDs vPos 
   Leader = info_leader(PlatoonGUI.fig.Name,Velocity); 
end



% let sumo make a time step t=t+dt
traci.simulationStep();% all states are now in the next step, which somehow
                       % cancels the delay of the output

% get a list of all vehicles that are arrived in SUMO now
% needed for first appearance AND object signals
listOfCarsInSimulation = traci.vehicle.getIDList();                 

% get the indizes of all EGO-vehicles that arrived in simulation now
idxEgoCarsInSim = find( ismember( PlatoonGUI.fig.Name, listOfCarsInSimulation ) );
EgoCarsInSim    = intersect( PlatoonGUI.fig.Name, listOfCarsInSimulation );
% get all cars but the first ego car
ObjectsInSim    = setdiff( listOfCarsInSimulation, PlatoonGUI.fig.Name );  


% set all vehicles that are appeared in SUMO in SUMOVehicleUD
% set(allVehicle,'String',listOfCarsInSimulation);

%--------------------------------------------------------------------------
% This block sets one entry in block.Dwork(1).Data to true for each ego
% vehicle that arrived in the simulation.
% The first time a vehicle arrives there are some settings done, so that
% the vehicle velocity can be set more directly.
% In order to avoid sending/recieving overhead the checking and setting is
% only done until all vehicles are arrived.
% NOTE: the following assumption has to be kept:
% All ego cars may appear at different times but do not dissapear unil end!
%

if ~all( block.Dwork(1).Data )  
    % there are some vehicles left, which have not been arrived jet:
    for idxEgoCar = idxEgoCarsInSim                  % for all arrived cars
        if ~block.Dwork(1).Data(idxEgoCar)             % is the first run?
            if  SumoGui && idxEgoCar==1 % is first ego there and gui is on
                vid = traci.gui.getIDList();
                traci.gui.trackVehicle( vid{1}, EgoName{1} );     %track it
                traci.gui.setSchema( vid{1}, 'real world');
                traci.gui.setZoom(vid{1}, 1000);
            end
            % set vehicle settings at the first time
            traci.vehicle.setTau      ( EgoName{idxEgoCar}, 0.2    );
            % traci.vehicle.setSpeedMode( EgoName{idxEgoCar}, 0    );
            %traci.vehicle.setAccel    ( EgoName{idxEgoCar}, 1000 );
            %traci.vehicle.setDecel    ( EgoName{idxEgoCar}, 1000 );
            
%TODO --> for later improvement
%          % subscribe special signals for later bundled recieving
%          traci.vehicle.subscribe(EgoName{idxEgoCar},...
%                  { traci.constants.VAR_ANGLE,...
%                    traci.constants.VAR_SPEED, ...
%                    traci.constants.VAR_POSITION,...
%                    traci.constants.VAR_LANE_INDEX,...
%                    traci.constants.VAR_SIGNALS} );
%          VEH = traci.vehicle.getSubscriptionResults(EgoName{idxEgoCar});
%          VEH.values;
        end        
    end
    % store flags of all arrived vehicles
    block.Dwork(1).Data(idxEgoCarsInSim) = 1; 
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% update SUMO egoCar velocity with the simulation position and velocity
% in order to syncronize the position
SimEgoVelocity = zeros(NumberOfCars,1);
for idxEgoCar = 1:NumberOfCars
    SimEgoVelocity(idxEgoCar,:) = block.InputPort(1).Data(idxEgoCar);
end

EgoTargetLane = block.InputPort(2).Data;
v_set = updateSUMO( SimEgoVelocity,...
                    {PlatoonGUI.fig.Name}, SumoTs, EgoCarsInSim, EgoTargetLane);

% for idx = 1:numel(ObjectsInSim)  
%     traci.vehicle.slowDown(ObjectsInSim{idx},idx*5,2);
% end
                       

%--------------------------------------------------------------------------
% allocate mem

% Nr_Follower = length(Follower);
% Nr_Follower_in = length(Leader.Platoon);
% 
% if Nr_Follower_in > Nr_Follower
%     qwsadc = Nr_Follower_in - Nr_Follower;
%     Leader.Platoon(end+1-qwsadc:end) = [];
% end

kT      = block.DialogPrm(11).Data;
V       = block.DialogPrm(12).Data;
SumoTs  = block.DialogPrm(1).Data;  
r       = block.InputPort(5).Data;
v_i1    = block.Dwork(3).Data;
for idxEgoCar = 1:length(find(block.Dwork(1).Data))
    Leader(idxEgoCar) = Leader(idxEgoCar).update;
    Leader(idxEgoCar) = Leader(idxEgoCar).getNewSpeed(kT,SumoTs,V,r,v_i1);
end
% Leader.velocity.v



if Leader.InPlatoon == 3 && ~isempty(Leader.NewLeader.To)
    traci.vehicle.setColor(Leader.ID,Leader.Color.Yellow)
    
    Leader.ID = Leader.NewLeader.To{1};
    traci.vehicle.setColor(Leader.ID,Leader.Color.Green)
    Leader.InPlatoon = 1;
    Leader.NewLeader.To = '';
    Leader.NewLeader.Type = 0;
    Leader = Leader.update;
    Leader.camera;
    PlatoonGUI.fig.Name = Leader.ID;
    for idx = 1:numel(Follower)
        if strcmp(Leader.ID, Follower(idx).ID)
            Follower(idx) = [];
            Leader.Platoon(idx) = [];
            break;
        end
    end
end



% ObjSignals     = block.InputPort(3).Data;
% leaderSignals  = zeros(NumVehicles,1);

% textMessage    = PlatoonGUI.TextMessage.String;
% platoonVehicle = findobj(PlatoonGUI,'Tag','PlatoonVehicle');
% platoonUD      = get(PlatoonGUI,'UserData');


% Follower          = get(ObjVehicles,'UserData');
% NearVehicles   = findobj(ObjVehicles,'Tag','NearVehicle');
ObjSignals = zeros(numel(Follower),1);
for idx = 1:numel(Follower)
    ObjSignals(idx) =  Follower(idx).sig;
    ObjID(idx)      = {Follower(idx).ID};
    dxObj(idx)      =  Follower(idx).dist(1);
    dyObj(idx)      =  Follower(idx).dist(2);
end

vObj  = block.InputPort(4).Data(1,:);
% dxObj = block.InputPort(4).Data(2,:);
% dyObj = block.InputPort(4).Data(3,:);

signalsIdx = find(ObjSignals);
if Leader.sig == 2 && checkSignal == 0
    temp = Leader.ID;

    PlatoonGUI.TextMessage.String = join(['Vehicle ' temp...
    ' wants to leave the platoon. Do you want to accept it?']);
    traci.vehicle.setColor(temp,RFGColor.Pink);
    Leader = Leader.getSignal(Leader.ID,Leader.sig);
    PlatoonGUI.AcceptReq.Enable = 'on';
    PlatoonGUI.DeclineReq.Enable = 'on';
    checkSignal = 1;
elseif ~isempty(signalsIdx) && checkSignal == 0
    switch length(signalsIdx)
    case 1
        if ObjSignals(signalsIdx) == 1
            temp = ObjID{signalsIdx};

            PlatoonGUI.TextMessage.String = join(['Vehicle ' temp...
                ' want to join the platoon. Do you want to accept it?']);
            if dxObj(signalsIdx) >= 0
                Leader = Leader.getSignal(ObjID{signalsIdx},20);
            else
                Leader = Leader.getSignal(ObjID{signalsIdx},ObjSignals(signalsIdx));
            end
            traci.vehicle.setColor(temp,RFGColor.Orange);
            PlatoonGUI.AcceptReq.Enable = 'on';
            PlatoonGUI.DeclineReq.Enable = 'on';
            checkSignal = 1;
            
        elseif ObjSignals(signalsIdx) == 2
            temp = ObjID{signalsIdx};

            PlatoonGUI.TextMessage.String = join(['Vehicle ' temp...
                ' want to leave the platoon. Do you want to accept it?']);
            Leader = Leader.getSignal(ObjID{signalsIdx},ObjSignals(signalsIdx));
        
            PlatoonGUI.AcceptReq.Enable = 'on';
            PlatoonGUI.DeclineReq.Enable = 'on';
            traci.vehicle.setColor(temp,RFGColor.Pink);
            checkSignal = 1;
        end
    otherwise
        d = sqrt(dxObj.^2+dyObj.^2);
        [min_d, idx_d] = min(d(signalsIdx));

        signalsIdx = signalsIdx(idx_d);

        if ObjSignals(signalsIdx) == 1
            temp = ObjID{signalsIdx};

            PlatoonGUI.TextMessage.String = join(['Vehicle ' temp...
                ' want to join the platoon. Do you want to accept it?']);
           
            Leader= Leader.getSignal(ObjID{signalsIdx},ObjSignals(signalsIdx));
            traci.vehicle.setColor(temp,RFGColor.Orange);
            PlatoonGUI.AcceptReq.Enable = 'on';
            PlatoonGUI.DeclineReq.Enable = 'on';
            checkSignal = 1;
        elseif ObjSignals(signalsIdx) == 2
            temp = ObjID{signalsIdx};

            PlatoonGUI.TextMessage.String = join(['Vehicle ' temp...
                ' want to leave the platoon. Do you want to accept it?']);
            
            Leader = Leader.getSignal(ObjID{signalsIdx},ObjSignals(signalsIdx));
        
            PlatoonGUI.AcceptReq.Enable = 'on';
            PlatoonGUI.DeclineReq.Enable = 'on';
            traci.vehicle.setColor(temp,RFGColor.Pink);
            checkSignal = 1;
        end
    end
end

% if strcmp(Leader.Platoon(end-1).ID,Leader.Platoon(end).ID)
%     Leader.Platoon(end) = [];
% end

% platoonUD.Signals(find(ObjSignals == 0)) = 0;

% if ~isempty(find(platoonUD.InPlatoon))
%     controller = 1
% end


% v_new = control(block,EgoVel,platoonUD);

% [y,v0] = fcn(block.InputPort(4).Data,EgoVel,platoonUD.InPlatoon);

% kT = block.DialogPrm(11).Data;
% V  = block.DialogPrm(12).Data;
% r = -15;

% a = kT*y + V*r;


% if ~isempty(ObjectsInSim)
%     for idx = 1:numel(ObjectsInSim)
%         tic
%         obj_veh(idx) = inf_veh(ObjectsInSim{idx});
%         toc
%     end
% end



block.OutputPort(1).Data = Leader.Vel;
block.Dwork(3).Data = Leader.Vel;
% block.OutputPort(2).Data = EgoLane;
% block.OutputPort(3).Data = EgoVel;
% block.OutputPort(4).Data = EgoPos;
% block.OutputPort(5).Data = platoonUD.Signals;
% block.OutputPort(6).Data = platoonUD.InPlatoon;
% block.OutputPort(7).Data = controller;
% block.OutputPort(8).Data = v_new;




%end Outputs
%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)
  traci.close();
  disp(['[OK] Terminating the block with handle ',...
        num2str(block.BlockHandle) '.']);

%end Terminate

%% HELPER functions
function [traciVersion,sumoVersion] = initSUMO( PAR )
% check SUMO paths and TraCI
  checkInstallation();
    
  % add missing options
  if PAR.gui
      PAR.sumoExe  = 'sumo-gui';
  else
      PAR.sumoExe  = 'sumo';
  end
  
  if ~isfield(PAR,'sumoOptions'), PAR.sumoOptions='';     end
  if ~isfield(PAR,'port'),        PAR.port = 8873;        end
  if ~isfield(PAR,'ipName'),      PAR.ipName='127.0.0.1'; end
  
  % adapt fileseperator for specific platform
  PAR.scenarioPath = regexprep(PAR.scenarioPath,{'\','/'},...
                     {filesep,filesep});
  if ~(exist(PAR.scenarioPath,'file')==2)
      error(['[error] SUMO config file not found: ',PAR.scenarioPath]);
  end
  
  % Start SUMO
  if strcmp(PAR.ipName,'127.0.0.1') || strcmp(PAR.ipName,'localhost')
      system( [PAR.sumoExe,' --configuration-file ',PAR.scenarioPath,...
          ' --remote-port ',num2str(PAR.port),...
          ' --step-length ',num2str(PAR.dt),...
          ' --ignore-accidents true ',...
          ' --quit-on-end ',...
          ' --time-to-teleport -1 ',...
          ' --time-to-teleport.highways -1 ',...
          ' --lanechange.duration 5 ',...
          ...%' --full-output sumoSimLog.txt ',...
          ' --start ',PAR.sumoOptions,...
          ' &']);
  else
      % NOTE if IP is not 127.0.0.1 (localhost) ->exefile has to be started
      % on a remote PC!!
      uiwait(msgbox({'Please start SUMO on ',...
          ['  remote computer ', PAR.ipName],...
          ['  at port ',num2str(PAR.port)]}));
  end
  
  % Initialize TraCI
  import traci.constants.*
  [traciVersion,sumoVersion] = traci.init( PAR.port,...
      'label', 'deault',...
      'host',PAR.ipName);
  
  fprintf( 'SUMO version: %s\nTraCI version: %d\n',...
      sumoVersion, traciVersion );


function checkInstallation
  % check if SUMO_HOME path is set
  p = getenv('SUMO_HOME');
  if isempty(p)
      errordlg({'No SUMO_HOME environemnt variable found!',...
          'Please set SUMO_HOME env.-var. in your OS'});
      error('No SUMO_HOME environemnt variable found!');
  else
      fprintf('[OK]   SUMO_HOME variable found %s\n',p);
  end

  % check for sumo on path
  [s,~] = system('sumo');
  if s==1
      errordlg('No SUMO executable found on your OS-path!');
      error('No SUMO executable found on your OS-path!');
  else
      fprintf('[OK]   SUMO.exe found.\n');
  end

  % check if SUMO_TRACI path is set
  if isempty(which('traci.getVersion'))
      p = getenv('SUMO_TRACI');
      if isempty(p)
          errordlg('Please set SUMO_TRACI env.-var. in your OS',...
              'or add SUMO TraCI to your MATLAB path');
          error(['No MATLAB interface for SUMO found.',...
                 ' Add it manually or set environment variable!']);
      else
          fprintf('[OK]   TraCi MATLAB Interface for SUMO found.\n');
      end
      addpath(genpath(p));
      
  else
      fprintf('[OK]   TraCi MATLAB Interface for SUMO found.\n');
  end
  
function terminateSUMO()
% close SUMO connection
  try                                             % try to close connection
      traci.close();
      fprintf('[OK]   closed SUMO interface.\n');
  catch err                                   %#ok<NASGU> % report problems
      fprintf('[error] problems closing SUMO interface.\n');
  end

function vPos = odometerCalc( vPos, EgoName )
% this odometer is used for traffic light distance calculation.
% Note: the calculated distance does not take into account the distances
% travelled over junctions, therefore this is always less than the
% travelled distance which is stored in sfunction local dwork variable
%
% save new positions to detect changes
  vPos.lanePos(1,2)  = traci.vehicle.getLanePosition(EgoName);
  vPos.roadName{1,2} = traci.vehicle.getRoadID(EgoName);
  vPos.laneName{1,2} = traci.vehicle.getLaneID(EgoName);
  % detect changes
  vPos.sameLane      = strcmp( vPos.laneName{1}, vPos.laneName{2} );
  vPos.sameRoad      = strcmp( vPos.roadName{1}, vPos.roadName{2} );
  % odometer
  if vPos.sameRoad
      vPos.ds = diff(vPos.lanePos);
  else
      oldLanePart   = traci.lane.getLength(vPos.laneName{1}) - ...
                           vPos.lanePos(1);
      vPos.ds = oldLanePart + vPos.lanePos(2);      
  end
  % swap new to old
  vPos.laneName{1} = vPos.laneName{2};
  vPos.roadName{1} = vPos.roadName{2};
  vPos.lanePos(1)  = vPos.lanePos(2);
  
   vPos.s =  vPos.s + vPos.ds;


function vPos = odometerInit( EgoName )
  % for odometer
  % save old position (first time) to detect changes
  vPos.lanePos(1,1)    = traci.vehicle.getLanePosition(EgoName);
  vPos.laneName{1,1}   = traci.vehicle.getLaneID(EgoName);
  vPos.roadName{1,1}   = traci.vehicle.getRoadID(EgoName);
  vPos.s = 0;
  
function v_set = updateSUMO( SimVel, EgoName,...
                             SumoTs, SumoVehIds, EgoTargetLane )
% v_set = updateSUMO( p, v, ego, tsSumo ) syncs a number of ego-vehicles
% between SIMULINK and SUMO
%
% SimPos .... required positions of ego vehicles (nx2)-vector (X,Y per row)
% SimVel .... either a colomn of scalar velocities or (nx2) vector
% Ego ....... list of n ego vehicle names for syncing
% SumoTs .... sampling period
% SumoVehIds. cell array of vehicle ids in sim. (to check if ego is active)
%
% Note:
%   all values are SI [m], [m/s], [s]
%   X is horizontal
%   Y is vertical

n      = numel(EgoName); % number of vehicles to sync

try
  % get the indizes of all EGO-vehicles that are arrived in the simulation
  idxEgoCarsInSim = find(ismember( EgoName, SumoVehIds ));  
  
  % if at least one EGO-vehicle is arrived
  if ~isempty(idxEgoCarsInSim)
    
    %------------------------------------------------------------------ 
    v_set = SimVel;
    
    for idxEgoCar=idxEgoCarsInSim
      traci.vehicle.slowDown( EgoName{idxEgoCar}, v_set( idxEgoCar ),5 );
      
      %% ADAPT TO MULTILANE HERE
      traci.vehicle.changeLane( EgoName{idxEgoCar},...
                                EgoTargetLane(idxEgoCar), 10 );
    end
    
  end
  
catch me %#ok<NASGU>
  terminateSUMO();
end




function [y,v0] = fcn(u,v_leader,flags)

v  = u(1,:);
dx = u(2,:);
dy = u(3,:);

edx = zeros(length(v),1);
edy = zeros(length(v),1);
ev  = zeros(length(v),1);
ed  = zeros(length(v),1);

% v0 = zeros(1,NumVehicles);
% y  = zeros(2,NumVehicles);

idx = find(flags);
if ~isempty(idx)
    d = sqrt(dx(idx).^2 + dy(idx).^2);
    [dist,sortIdx] = sort(d);
    temp = idx(sortIdx);
    switch length(temp)
        case 1
            edx(temp) = dx(temp);
            edy(temp) = dy(temp);
            ev(temp)  = v(temp) - v_leader;
            ed  = -sqrt(edx.^2 + edy.^2);
        otherwise
            edx(temp(1)) = dx(temp(1));
            edy(temp(1)) = dy(temp(1));
            edx([temp(2:end)]) = dx([temp(2:end)]) - dx([temp(1:end-1)]);
            edy([temp(2:end)]) = dy([temp(2:end)]) - dy([temp(1:end-1)]);
            
            ev(temp(1)) = v(temp(1)) - v_leader;
            ev([temp(2:end)]) = v([temp(2:end)]) - v([temp(1:end-1)]);

            ed  = -sqrt(edx.^2 + edy.^2);
    end
end
y = [ed,ev]';
v0 = v;
    
function v_new = control(block,EgoVel,platoonUD) 
    [y,v0] = fcn(block.InputPort(4).Data,EgoVel,platoonUD.InPlatoon);

    kT      = block.DialogPrm(11).Data;
    V       = block.DialogPrm(12).Data;
    SumoTs  = block.DialogPrm(1).Data;  
    r = -15;

    a = -kT*y + V*r;

    a = min(3,max(a,-5));
    v_new = a*SumoTs + v0;