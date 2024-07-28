function sf2SUMO_SYNC(block)
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
block.NumOutputPorts = 4;
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

% Override input port properties
if ~iscell(block.DialogPrm(2).Data)
    NumberOfEgos = 1;
else
    NumberOfEgos = numel(block.DialogPrm(2).Data);
end
for idx_input=1:block.NumInputPorts
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
%n = block.DialogPrm(3).Data;

% sumo time
block.OutputPort(1).Dimensions  = 1;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';

% ego vehicle validation (v, x, y, s)
block.OutputPort(2).Dimensions  = 5;
block.OutputPort(2).DatatypeID  = 0; % double
block.OutputPort(2).Complexity  = 'Real';
block.OutputPort(2).SamplingMode = 'Sample';

% GPS
block.OutputPort(3).Dimensions  = 9;
block.OutputPort(3).DatatypeID  = 0; % double
block.OutputPort(3).Complexity  = 'Real';
block.OutputPort(3).SamplingMode = 'Sample';

% Object data
block.OutputPort(4).Dimensions  = [9, block.DialogPrm(3).Data];
block.OutputPort(4).DatatypeID  = 0; % double
block.OutputPort(4).Complexity  = 'Real';
block.OutputPort(4).SamplingMode = 'Sample';

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
  
  close all
  global checkSignal;
  checkSignal = 0;
  NumVehicles = block.DialogPrm(3).Data;
  NumEgoName  = numel(block.DialogPrm(2).Data);
 

  
  % Tag: AllVehicle
  % Tag: FollowerVehicle
  % Tag: NearVehicle
  % Tag: joinReq
  % Tag: leaveReq
  % Tag: SUMO_Vehicles
fig.SUMOVehicle = SUMO_Vehicle;
  
  
  % Tag: PlatoonVehicle
  % Tag: textMessage
  % Tag: acceptReq
  % Tag: declineReq
  % Tag: figure1
  fig.PlatoonGUI  = platoon;
  
  sz = [NumVehicles + NumEgoName, 5];
  varNames = {'IDs','Velocity','Position','Signals','Flag'};
  varTypes = {'cell','table','table','table','double'};
  
  SUMOVehicleUD = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
  
  SUMOVehicleUD.Velocity = table('Size',[NumVehicles + NumEgoName, 2],...
      'VariableTypes',{'double','double'},...
      'VariableNames',{'x','y'});
  
  SUMOVehicleUD.Position = table('Size',[NumVehicles + NumEgoName, 2],...
      'VariableTypes',{'double','double'},...
      'VariableNames',{'x','y'});
  
  SUMOVehicleUD.Signals = table('Size',[NumVehicles + NumEgoName, 4],...
  'VariableTypes',{'cell','cell','double','double'},...
  'VariableNames',{'From','To','Type','Wait'});
  vehiclesData.current  = SUMOVehicleUD;
  vehiclesData.previous = SUMOVehicleUD;

  set(fig.SUMOVehicle,'UserData',vehiclesData);
%------------------------------------
  sz = [NumVehicles + NumEgoName, 5];
  varNames = {'Nr','IDs','Velocity','Position','Signals'};
  varTypes = {'double','cell','table','table','table'};
  
  UD = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
  
  SUMOVehicleUD.Velocity = table('Size',[NumVehicles + NumEgoName, 2],...
      'VariableTypes',{'double','double'},...
      'VariableNames',{'x','y'});
  
  SUMOVehicleUD.Position = table('Size',[NumVehicles + NumEgoName, 2],...
      'VariableTypes',{'double','double'},...
      'VariableNames',{'x','y'});
  
  SUMOVehicleUD.Signals = table('Size',[NumVehicles + NumEgoName, 4],...
  'VariableTypes',{'cell','cell','double','double'},...
  'VariableNames',{'From','To','Type','Wait'});

  PlatoonData.current  = UD;
  PlatoonData.previous = UD


  set(fig.PlatoonGUI ,'UserData',PlatoonData);
  
  set_param(gcbh,'UserData',fig);
  
  % open connection to Sumo
  SumoParam.dt            = block.DialogPrm(1).Data;
  SumoParam.scenarioPath  = block.DialogPrm(4).Data;
  SumoParam.ip            = block.DialogPrm(5).Data;
  SumoParam.port          = block.DialogPrm(6).Data;
  SumoParam.gui           = block.DialogPrm(7).Data;
  SumoParam.sumoOptions   = block.DialogPrm(8).Data;
  
  % initialize ego visible indicator
  block.Dwork(1).Data = 0*block.Dwork(1).Data; % init appearFlag
  block.Dwork(2).Data = 0*block.Dwork(2).Data; % init traveldist
  
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
global checkSignal;
fig = get_param(gcbh,'UserData');
SUMOVehicleUD  = get(fig.SUMOVehicle,'UserData');
platoonGUIUD   = get(fig.PlatoonGUI,'UserData');
  
% allVehicle      = findobj(fig.SUMOVehicle,'Tag','AllVehicle'     );
nearVehicle     = findobj(fig.SUMOVehicle,'Tag','NearVehicle'    );
followerVehicle = findobj(fig.SUMOVehicle,'Tag','FollowerVehicle');
leaderVehicle   = findobj(fig.SUMOVehicle,'Tag','LeaderVehicle'  );
platoonVehicle  = findobj(fig.PlatoonGUI ,'Tag','PlatoonVehicle' );
textMessage     = findobj(fig.PlatoonGUI ,'Tag','textMessage'    );

% Convenience declerations ------------------------------------------------
SumoTs       = block.DialogPrm(1).Data;                % SUMO sampling time
if ~iscell(block.DialogPrm(2).Data)
    EgoName  = {block.DialogPrm(2).Data};
else
    EgoName  = block.DialogPrm(2).Data;
end
SumoGui      = block.DialogPrm(7).Data;
NumberOfCars = numel(EgoName);
set(leaderVehicle,'String',EgoName);
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
end


% let sumo make a time step t=t+dt
traci.simulationStep();% all states are now in the next step, which somehow
                       % cancels the delay of the output

% get a list of all vehicles that are arrived in SUMO now
% needed for first appearance AND object signals
listOfCarsInSimulation = traci.vehicle.getIDList();                 

% get the indizes of all EGO-vehicles that arrived in simulation now
idxEgoCarsInSim = find( ismember( EgoName, listOfCarsInSimulation ) );
EgoCarsInSim    = intersect( EgoName, listOfCarsInSimulation );
% get all cars but the first ego car
ObjectsInSim    = setdiff( listOfCarsInSimulation, EgoName{1}  );  


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
            traci.vehicle.setAccel    ( EgoName{idxEgoCar}, 1000 );
            traci.vehicle.setDecel    ( EgoName{idxEgoCar}, 1000 );
            
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
                    EgoName, SumoTs, EgoCarsInSim, EgoTargetLane);

% for idx = 1:numel(ObjectsInSim)  
%     traci.vehicle.slowDown(ObjectsInSim{idx},idx*5,2);
% end
                
                
        block.Dwork(1).Data        

%--------------------------------------------------------------------------
% allocate mem
EgoPos  = zeros(NumberOfCars,2); % position of ego vehicle [x_glob, y_glob]
EgoVel  = zeros(NumberOfCars,1); % absolute velocity of ego vehicle 
EgoAng  = zeros(NumberOfCars,1); % direction of ego vehicle & its velocity
EgoVMax = zeros(NumberOfCars,1); % maximum allowed velocity at actual lane
EgoNLaneWidth = zeros(NumberOfCars,1); % width of actual lane
for idxEgoCar = 1:length(find(block.Dwork(1).Data))
    % read out velocity values (at t) from old sample (t-dt)
    EgoVel(idxEgoCar,1) = traci.vehicle.getSpeed   (EgoName{idxEgoCar});
    % from actual sample (at t)    
    EgoPos(idxEgoCar,:) = traci.vehicle.getPosition(EgoName{idxEgoCar});
    % read out angle at t
    EgoAng(idxEgoCar,1) = traci.vehicle.getAngle   (EgoName{idxEgoCar});
    %
    laneID              = traci.vehicle.getLaneID   (EgoName{idxEgoCar});
    EgoVMax(idxEgoCar,1)       = traci.lane.getMaxSpeed(laneID);
    EgoNLaneWidth(idxEgoCar,1) = traci.lane.getWidth(laneID);
end

%% assign outputs
%% time checking port (for debugging)--------------------------------------
block.OutputPort(1).Data = t; 
%% ego vehicle port -------------------------------------------------------
% write information of SUMO ego vehicle (X,Y,V,distance travelled, angle)
% block.OutputPort(2).Data = [ EgoPos'; EgoVel'; ...
%                              block.Dwork(2).Data';EgoAng' ];

% GPS port ----------------------------------------------------------------
block.OutputPort(3).Data = zeros(9,1);

    [EgoLon,EgoLat] = traci.simulation.convertGeo(EgoPos(1,1),EgoPos(1,2));
%   long position .......................... [deg] longitude
    %NOTE: only works for proper net definitions, fallback is X
    block.OutputPort(3).Data(1) = EgoLon;
%   latt position .......................... [deg] lattitude
    %NOTE: only works for proper net definitions, fallback is Y
    block.OutputPort(3).Data(2) = EgoLat;
%   total height over sea level ............ [m]
    % currently not implemented, subject to further development
    block.OutputPort(3).Data(3) = 0;
%   heading angle .......................... [deg] (compass)
    block.OutputPort(3).Data(4) = EgoAng(1);
%   traveling velocity ..................... [m/s] 
    block.OutputPort(3).Data(5) = EgoVel(1);
%   inclination ............................ [%]
    % currently not implemented, subject to further development
    block.OutputPort(3).Data(6) = 0;
%   maximum velocity ....................... [m/s]
    block.OutputPort(3).Data(7) = EgoVMax(1);
%   lanes width ............................ [m]  
    block.OutputPort(3).Data(8) = EgoNLaneWidth(1);
%   street type ............................ [-] 0..highway, 1..urban  
    % currently not implemented, subject to further development
    block.OutputPort(3).Data(9) = 1;

%% Traffic objects --------------------------------------------------------
% for convinence
NumberObjectsMax         = block.DialogPrm(3).Data;
RangeObjectsMax          = block.DialogPrm(10).Data;
% set all to zero
d = block.OutputPort(4).Dimensions;
block.OutputPort(4).Data = zeros(d(1), d(2)); 



%--------------------------------------------------------------
%% SUMO is the reference
RefPosEgo = EgoPos(1,:); 
%% calculate angle (rad) from angle (compass) of ego vehicle
%% in order to project vectors to ego vehicle coordinate system
RefAngEgo = -(EgoAng(1)-90)*pi/180;   % compass angle --> rad

% % Veh Sim is the reference
% RefPosEgo = SimEgoPosition(1,:);        % Vehicle Sim is the reference 
% RefAngEgo = block.InputPort(5).Data(1); % directly in rad

% get data from SUMO objects ----------------------------------
ObjectPos = NaN*zeros(numel(ObjectsInSim),2);
for idxObj = 1:numel(ObjectsInSim)
    ObjectPos(idxObj,:) = traci.vehicle.getPosition(ObjectsInSim{idxObj});  
end

% calc distance vectors between first ego vehicle and all objects
DistXY        = ObjectPos - repmat(RefPosEgo,numel(ObjectsInSim),1);
% calc euclidian distance between fisrt ego vehicle and all objects
DistL         = sqrt(sum(DistXY.*DistXY,2));
% find index of sorted distances
[~,IndexOfSortDist]  = sort(DistL);
indSortDis = IndexOfSortDist;
% get the indizes of the most relevant objects, but not more than specified
IndexOfSortDist      = IndexOfSortDist(1:min(NumberObjectsMax,end));


% get the names of the most relevant objects
CloseByObjects       = ObjectsInSim(IndexOfSortDist)';
% extract the first objects but not more than NumberObjectsMax 
DistXY               = DistXY(IndexOfSortDist,:);
DistL                = DistL(IndexOfSortDist,:);

% remove entries out of sensor range
if RangeObjectsMax>0 
    IndexOutOfSensorRange                 = find(DistL>RangeObjectsMax);
    DistXY(IndexOutOfSensorRange,:)       = [];
    CloseByObjects(IndexOutOfSensorRange) = [];
end

% get additional info to the relevant objects
NumberOfRelevantObjects = numel(CloseByObjects);
ObjectAng  = NaN*zeros(NumberOfRelevantObjects,1);
ObjectVel  = NaN*zeros(NumberOfRelevantObjects,1);
ObjectSig  = NaN*zeros(NumberOfRelevantObjects,1);
ObjectLan  = NaN*zeros(NumberOfRelevantObjects,1);
for idxObj=1:NumberOfRelevantObjects
    ObjectAng(idxObj,:)=traci.vehicle.getAngle    (CloseByObjects{idxObj});
    ObjectVel(idxObj,:)=traci.vehicle.getSpeed    (CloseByObjects{idxObj});
    ObjectSig(idxObj,:)=traci.vehicle.getSignals  (CloseByObjects{idxObj});
    ObjectLan(idxObj,:)=traci.vehicle.getLaneIndex(CloseByObjects{idxObj});
end

% calculate angle (rad) from angle (compass) of ego vehicle
% in order to project vectors to ego vehicle coordinate system
RotAng     = RefAngEgo;
% calculate rotation matrix to bring world coordinates/vectors to 
% ego vehicle coordinate system
RotMat     = [ cos(RotAng), sin(RotAng);...
              -sin(RotAng), cos(RotAng) ];
% distance vector in ego coordinate system             
DistXY = (RotMat*DistXY')';

% absolute vector of velocity in ego coordinate system
ObjectAng  = -(ObjectAng-90)*pi/180;
AboluteVel = [ ObjectVel.*cos(ObjectAng), ObjectVel.*sin(ObjectAng) ];
AboluteVel = (RotMat*AboluteVel')';


% persitant variable storing the object IDs at the output
% this is used to have consitent signals and additionally to indicate new
% objects
persistent objIDs
if isempty(objIDs)
   objIDs   = cell(NumberObjectsMax,1);
   objIDs(:)={''};
end

% set all object ids from last step to '' which are now not included
objIDs( ismember(objIDs,setdiff(objIDs,CloseByObjects)) ) = {''};

% find places to insert the obects data and mark new objects
objectIndex   = zeros(numel(CloseByObjects),1);
objectNewFlag = zeros(numel(CloseByObjects),1);
% for i=1:numel(CloseByObjects) % for all objects
%     % look if and where the object is in the old list
%     [objectExists, objectIndPos] = ismember(CloseByObjects{i},objIDs);
%     if ~objectExists % if this is a new object find a place to insert
%         % usually matlab finds the last possible entry --> reverse order
%         [~, objectIndPos] = ismember('',objIDs(end:-1:1));
%         objectIndPos = numel(objIDs)-objectIndPos+1;
%         % set new flag for the object
%         objectNewFlag(i) = 1;
%         % store the new object in the list and remove this free slot
%         objIDs(objectIndPos) = CloseByObjects(i);
%     end
%     % store position of the object in the output signal
%     objectIndex(i) = objectIndPos;
% end

for i=1:numel(CloseByObjects) % for all objects
    % look if and where the object is in the old list
    [objectExists, objectIndPos] = ismember(CloseByObjects{i},objIDs);
    if ~objectExists % if this is a new object find a place to insert
        % usually matlab finds the last possible entry --> reverse order

        [~, objectIndPos] = ismember('',objIDs);
        % set new flag for the object
        objectNewFlag(i) = 1;
        % store the new object in the list and remove this free slot
        objIDs(objectIndPos) = CloseByObjects(i);
        % asd = untitled123456;
        % set(asd,'Name',CloseByObjects{i});
        % fig.obj(i) = asd;
    end
    % store position of the object in the output signal
    objectIndex(i) = objectIndPos;
end


% for m = 1:numel(closeObj)
%     temp = find(strcmp(closeObj(m), objIDs))
%     if isempty(temp)
%     asd = find(strcmp({''}, objIDs));
%     objIDs(asd(1)) = closeObj(m);
%     idx(m) = find(strcmp(closeObj(m), objIDs));
%     else
%     idx(m) = temp;
%     end
%     end

% velo = block.InputPort(3).Data
% global IDsVeh;
% global qwe;
% if t == 0
%     IDsVeh = {};
%     qwe = cell(NumberObjectsMax,1);
%     qwe(:) = {''};
% end
% IDsVeh = ObjectsInSim(indSortDis);
% %CloseByObjects(objectIndex)
% asd = cell(NumberObjectsMax,1);
% asd(:) = {''};
% objectIndex;
% CloseByObjects;
% asd(objectIndex) = CloseByObjects;
% qwe = asd;


SUMOVehicleUD.current.IDs(1:numel(objIDs))    = objIDs;
SUMOVehicleUD.current.Flag(objectIndex)       = 1 + objectNewFlag;
SUMOVehicleUD.current.Velocity.x(objectIndex) = AboluteVel(:,1);
SUMOVehicleUD.current.Velocity.y(objectIndex) = AboluteVel(:,2);
SUMOVehicleUD.current.Position.x(objectIndex) = DistXY(:,1);
SUMOVehicleUD.current.Position.y(objectIndex) = DistXY(:,2);


temp = 1:numel(objIDs);
SUMOVehicleUD.current.Velocity.x(ismember(temp,setdiff(temp,objectIndex))) = 0;
SUMOVehicleUD.current.Velocity.y(ismember(temp,setdiff(temp,objectIndex))) = 0;
SUMOVehicleUD.current.Position.x(ismember(temp,setdiff(temp,objectIndex))) = 0;
SUMOVehicleUD.current.Position.y(ismember(temp,setdiff(temp,objectIndex))) = 0;

if ~isempty(SUMOVehicleUD.current.Signals.Type) && checkSignal == 0
    qweasdzxc = SUMOVehicleUD.current.Signals.Type;

    idx = find(qweasdzxc);
    NrOfRequest = length(idx);
    switch NrOfRequest
        case 0
            % nothing to do
        case 1
            temp = SUMOVehicleUD.current.IDs{idx};
            IDsSaving(temp);
            AcceptReq = findobj(fig.PlatoonGUI,'Tag','acceptReq');
            DeclineReq = findobj(fig.PlatoonGUI,'Tag','declineReq');
            set(textMessage,'String',join({'Vehicle' temp 'want to join the platoon. Do you want to accept it?'}));
            set(AcceptReq,'Enable','on');
            set(DeclineReq,'Enable','on');
            checkSignal = 1;
        otherwise
            % [~,Index] = min(abs(figUDFollower.dist(idx)));
            % temp = figUDFollower.IDs(idx);
            % temp = temp{Index};
            % IDsSaving(temp);
            % text1.String = join({'Vehicle' temp 'want to join the platoon. Do you want to accept it?'});
            % accept_btn.Enable = 'on';
            % decline_btn.Enable = 'on';
            % checkSignal = 1;
    end
end

if find(SUMOVehicleUD.current.Position.x > 0)
    qweasd = find(SUMOVehicleUD.current.Position.x > 0)
    if ~isempty(qweasd)
        SUMOVehicleUD.current.IDs(qweasd)        = {''};
        SUMOVehicleUD.current.Flag(qweasd)       = 0;
        SUMOVehicleUD.current.Velocity.x(qweasd) = 0;
        SUMOVehicleUD.current.Velocity.y(qweasd) = 0;
        SUMOVehicleUD.current.Position.x(qweasd) = 0;
        SUMOVehicleUD.current.Position.y(qweasd) = 0;
    end
end


SUMOVehicleUD.current

set(nearVehicle,'String',SUMOVehicleUD.current.IDs);



% for k = 1:length(objectIndex)
%     fprintf('IDs %s \n', CloseByObjects{k})
%     traci.vehicle.setSpeedMode(CloseByObjects{1+length(objectIndex)-k}, 0  );
%     traci.vehicle.setSpeed    (CloseByObjects{1+length(objectIndex)-k},velo(k));
%     traci.vehicle.setTau      (CloseByObjects{1+length(objectIndex)-k}, 0);
%     traci.vehicle.changeLane  (CloseByObjects{1+length(objectIndex)-k}, 0,t);
% end
fprintf('----------------------****************-------------\n')
% flag (0..off, 1..active, 2..new)
    block.OutputPort(4).Data(1,objectIndex) = 1 + objectNewFlag;
% dist x
    block.OutputPort(4).Data(2,objectIndex) = DistXY(:,1);
% dist y
    block.OutputPort(4).Data(3,objectIndex) = DistXY(:,2);
% vel x
    block.OutputPort(4).Data(4,objectIndex) = AboluteVel(:,1);
% vel y
    block.OutputPort(4).Data(5,objectIndex) = AboluteVel(:,2);
% lane
    block.OutputPort(4).Data(6,objectIndex) = ObjectLan;
% lateraloffset
    % not relevant for SUMO, since all cars go on edges
    block.OutputPort(4).Data(7,:) = zeros(1,NumberObjectsMax);
% brake signal
    block.OutputPort(4).Data(8,objectIndex) = ObjectSig;
% object width
    block.OutputPort(4).Data(9,objectIndex) = 2;    %TODO GET FROM SUMO

%%UPDATE
% incease traveled distance for all cars    
% block.Dwork(2).Data(idxEgoCarsInSim) = ...
%                       block.Dwork(2).Data(idxEgoCarsInSim) + v_set.*SumoTs;
SUMOVehicleUD.previous = SUMOVehicleUD.current;
set(fig.SUMOVehicle,'UserData',SUMOVehicleUD);
set_param(gcbh,'UserData',fig);

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
      traci.vehicle.slowDown( EgoName{idxEgoCar}, v_set( idxEgoCar ),4 );
      
      %% ADAPT TO MULTILANE HERE
      traci.vehicle.changeLane( EgoName{idxEgoCar},...
                                EgoTargetLane(idxEgoCar), 0 );
    end
    
  end
  
catch me %#ok<NASGU>
  terminateSUMO();
end


function [outputArg1] = IDsSaving(inputArg1)

    persistent loser;
    if nargin == 1
        loser = inputArg1;
        return
    elseif nargin == 0
        outputArg1 = loser;
    end