function leaderGUI(block)
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

block.OutputPort(4).Dimensions   = [2,x];
block.OutputPort(4).DatatypeID   = 0; % double
block.OutputPort(4).Complexity   = 'Real';
block.OutputPort(4).SamplingMode = 'Sample';




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
block.RegBlockMethod('SetInputPortSamplingMode', @SetInputPortSamplingMode);

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
global checkSignal;
checkSignal = 0;
FigureName = 'Leader Panel';
Fig = figure(...
        'Units',           'characters',...
        'Position',        [211.8000 1.3846 61.2000 26.9231],...
        'Name',            FigureName,...
        'NumberTitle',     'on',...
        'IntegerHandle',   'off',...
        'HandleVisibility','callback',...
        'Resize',          'on',...
        'MenuBar',         'none',...
        'ToolBar',         'none');
    
    
text1 = uicontrol(...
              'Parent',  Fig,...
              'Units','characters',...
              'Style',   'text',...
              'Position',[9.8000 7.5385 40.2000 3.9231],...
              'String',  'loser', ...
              'Interruptible','on',...
              'BusyAction','queue', ...
              'Tag','TextReq');
          
accept_req = uicontrol(...
              'Parent',  Fig,...
              'Style',   'pushbutton',...
              'Units','characters',...
              'Position',[3.8000 3.7692 13.8000 1.6923],...
              'String',  'Accept', ...
              'Callback',@AcceptReqCall,...
              'Interruptible','on',...
              'BusyAction','queue', ...
              'Tag','AcceptReq',...
              'Enable','off');
          
decline_req = uicontrol(...
              'Parent',  Fig,...
              'Style',   'pushbutton',...
              'Units','characters',...
              'Position',[36 3.7692 13.8000 1.6923],...
              'String',  'Decline', ...
              'Callback',@DeclineReqCall,...
              'Interruptible','on',...
              'BusyAction','queue', ...
              'Tag','DeclineReq',...
              'Enable','off');

          
follower_vehicle = uicontrol(...
              'Parent',  Fig,...
              'Style',   'listbox',...
              'String','',...
              'Units','characters',...
              'Position',[9.8000 14.0769 20.2000 11.5385],...
              'Callback',@FollowerVehiclesCall,...
              'Interruptible','on',...
              'BusyAction','queue', ...
              'Tag','FollowerVehicle');
          
    
follower_vehicle.String = ''; 

% 
% set(join_req,'Callback',{@JoinReqCall,near_vehicle})
  
FigUD.IDs = {''};
FigUD.vel = [];
FigUD.dist = [];
FigUD.accepted = [];
FigUD.declined = [];
FigUD.Nr = [];


set(Fig,'UserData',FigUD);
set_param(gcbh,'UserData',Fig);
%end Start




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

global checkSignal;
t         = block.InputPort(1).Data;
numObj    = block.DialogPrm(1).Data;
velocity  = zeros(numObj,1);
e         = zeros(numObj,1);
dist_ego  = block.InputPort(2).Data;
contro_on = 0;

d = block.OutputPort(4).Dimensions;
block.OutputPort(4).Data = zeros(d(1), d(2)); 

d_e = zeros(1,numObj);
v_e = zeros(1,numObj);

fig = get_param(gcbh,'UserData');
figUD = get(fig,'UserData');


followerBlock = 'Example_SOMU_SYNC/Follower/Level-2 MATLAB S-Function';
followerBlockHandle = get_param(followerBlock,'Handle');  

figFollower = get_param(followerBlockHandle,'UserData');
figUDFollower = get(figFollower,'UserData');

% FigUD.IDs 
% FigUD.vel 
% FigUD.dist 
% FigUD.joinReq 
% FigUD.leaveReq 


text1        = findobj(fig,'Tag','TextReq');
accept_btn   = findobj(fig,'Tag','AcceptReq');
decline_btn  = findobj(fig,'Tag','DeclineReq');
follower_veh = findobj(fig,'Tag','FollowerVehicle');
    


if ~isempty(figUDFollower.joinReq) && checkSignal == 0
    qweasdzxc = figUDFollower.joinReq;

    idx = find(qweasdzxc);
    NrOfRequest = length(idx);
    switch NrOfRequest
        case 0
            % nothing to do
        case 1
            temp = figUDFollower.IDs{idx};
            IDsSaving(temp);
            text1.String = join({'Vehicle' temp 'want to join the platoon. Do you want to accept it?'});
            accept_btn.Enable = 'on';
            decline_btn.Enable = 'on';
            checkSignal = 1;
        otherwise
            [~,Index] = min(abs(figUDFollower.dist(idx)));
            temp = figUDFollower.IDs(idx);
            temp = temp{Index};
            IDsSaving(temp);
            text1.String = join({'Vehicle' temp 'want to join the platoon. Do you want to accept it?'});
            accept_btn.Enable = 'on';
            decline_btn.Enable = 'on';
            checkSignal = 1;
    end
end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(follower_veh.String)
    idx = numel(follower_veh.String);
    if idx > 0
        EgoPos  = zeros(1,2); % position of ego vehicle [x_glob, y_glob]
        EgoVel  = zeros(1,1); % absolute velocity of ego vehicle 
        EgoAng  = zeros(1,1); % direction of ego vehicle & its velocity
        EgoVMax = zeros(1,1); % maximum allowed velocity at actual lane
        EgoNLaneWidth = zeros(1,1); % width of actual lane

        % read out velocity values (at t) from old sample (t-dt)
        EgoVel(1,1) = traci.vehicle.getSpeed   ('ego');
        % from actual sample (at t)    
        EgoPos(1,:) = traci.vehicle.getPosition('ego');
        % read out angle at t
        EgoAng(1,1) = traci.vehicle.getAngle   ('ego');
        %
        laneID              = traci.vehicle.getLaneID   ('ego');
        EgoVMax(1,1)       = traci.lane.getMaxSpeed(laneID);
        EgoNLaneWidth(1,1) = traci.lane.getWidth(laneID);

        RefPosEgo = EgoPos(1,:); 
        %% calculate angle (rad) from angle (compass) of ego vehicle
        %% in order to project vectors to ego vehicle coordinate system
        RefAngEgo = -(EgoAng(1)-90)*pi/180;   % compass angle --> rad

        % % Veh Sim is the reference
        % RefPosEgo = SimEgoPosition(1,:);        % Vehicle Sim is the reference 
        % RefAngEgo = block.InputPort(5).Data(1); % directly in rad

        % get data from SUMO objects ----------------------------------
        ObjectPos = NaN*zeros(numel(follower_veh.String),2);
        for idxObj = 1:numel(follower_veh.String)
            ObjectPos(idxObj,:) = traci.vehicle.getPosition(follower_veh.String{idxObj});  
        end

        % calc distance vectors between first ego vehicle and all objects
        DistXY        = ObjectPos - repmat(RefPosEgo,numel(follower_veh.String),1);
        % calc euclidian distance between fisrt ego vehicle and all objects


        NumberOfRelevantObjects = numel(follower_veh.String);
        ObjectAng  = NaN*zeros(NumberOfRelevantObjects,1);
        ObjectVel  = NaN*zeros(NumberOfRelevantObjects,1);
        % ObjectSig  = NaN*zeros(NumberOfRelevantObjects,1);
        % ObjectLan  = NaN*zeros(NumberOfRelevantObjects,1);
        for idxObj=1:NumberOfRelevantObjects
            ObjectAng(idxObj,:)=traci.vehicle.getAngle    (follower_veh.String{idxObj});
            ObjectVel(idxObj,:)=traci.vehicle.getSpeed    (follower_veh.String{idxObj});
            % ObjectSig(idxObj,:)=traci.vehicle.getSignals  (follower_veh.String{idxObj});
            % ObjectLan(idxObj,:)=traci.vehicle.getLaneIndex(follower_veh.String{idxObj});
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

        DistL  = sqrt(sum(DistXY.*DistXY,2));

        ObjectAng  = -(ObjectAng-90)*pi/180;
        AboluteVel = [ ObjectVel.*cos(ObjectAng), ObjectVel.*sin(ObjectAng) ];
        AboluteVel = (RotMat*AboluteVel')';

        AboluteVel = sqrt(sum(AboluteVel.*AboluteVel,2));
        if length(DistL) == 1
            e(1) = -abs(DistL);
            velocity(1) = AboluteVel(1);
            d_e(1) = -abs(DistL);
            v_e(1) = AboluteVel(1) - sqrt(sum(EgoVel.*EgoVel,2));
        else
            % idx = length(DistL);
            [~, distIdx] = sort(DistL(1:idx));
            dist(1,:) = DistXY(1,:);
            dist(2:idx,:) = DistXY(2:idx,:) - DistXY(1:idx-1,:);
            dist  = sqrt(sum(dist.*dist,2));
            


            
            figUD.Nr = 1:length(distIdx);
            dist = dist(distIdx);
            follower_veh.String = follower_veh.String(distIdx);

            % dist(1) = DistL(1);
            % dist(2:idx) = DistL(2:idx) - DistL(1:idx-1);
            e(1:idx)   = -abs(dist);
            d_e(1:idx) = -abs(dist);
            % velocity(1) = AboluteVel(1);
            % velocity(2:idx) = AboluteVel(2:idx);
            tempas = AboluteVel(1:idx);
            velocity(1:idx) = tempas(distIdx);
            v_e(1) = velocity(1) - sqrt(sum(EgoVel.*EgoVel,2));
            v_e(2:idx) = velocity(2:idx) - velocity(1:idx-1);
            figUD.IDs  = follower_veh.String;
            figUD.dist = DistL(distIdx);
            figUD.vel  = velocity;
        end
        contro_on = 1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if ~isempty(figUD.accepted)
%     [~,idx] = find(figUD.accepted);
%     if ~isempty(idx)
%     %     dist = traci.vehicle.getDistance('x');
%     % %     dist = sqrt(dist(1)^2 + dist(2)^2);
%     %     velocity = traci.vehicle.getSpeed('x');
%     %     dist_ego = traci.vehicle.getDistance('ego');
%     % %     dist_ego = sqrt(dist_ego(1)^2 + dist_ego(2)^2);
%     %     velocity_ego = traci.vehicle.getSpeed('ego');
%     figUD.dist(1:length(idx)) = figUDFollower.dist(idx);
%     figUD.vel(1:length(idx))  = figUDFollower.vel(idx);
%     if length(idx) == 1
%         dist = figUD.dist;
%         e(1) = -abs(dist);
%         velocity(1) = figUD.vel;
%     else
%         dist(1) = figUD.dist(1);
%         dist(2:length(idx)) = figUD.dist(2:length(idx)) - figUD.dist(1:length(idx)-1);
%         e = -abs(dist);
%         velocity = figUD.vel;
%     end
%     contro_on = 1;
% %     else
% %         follower_veh.UserData = 0;
% %         e = 0;
% %         velocity = 0;
%     end
% end

follower_Veh = findobj(figFollower,'Tag','FollowerVehicle');
followerVeh  = get(follower_Veh,'UserData');

followerVeh.LeaveReq.current
followerVeh.LeaveReq.previous
if ~isempty(followerVeh.LeaveReq.current)
    qweasdzxc = followerVeh.LeaveReq.current;

    idx = find(qweasdzxc);
    NrOfRequest = length(idx);
    switch NrOfRequest
        case 0
            % nothing to do
        case 1
            temp = followerVeh.IDs{idx};
            IDsSaving(temp);
            text1.String = join({'Vehicle' temp 'want to leave the platoon. Do you want to accept it?'});
            accept_btn.Enable = 'on';
            decline_btn.Enable = 'on';
        otherwise
            % [~,Index] = min(abs(figUDFollower.dist(idx)));
            % temp = figUDFollower.IDs(idx);
            % temp = temp{Index};
            % IDsSaving(temp);
            % text1.String = join({'Vehicle' temp 'want to leave the platoon. Do you want to accept it?'});
            % accept_btn.Enable = 'on';
            % decline_btn.Enable = 'on';
    end
end





block.OutputPort(1).Data = e;
block.OutputPort(2).Data = velocity;
block.OutputPort(3).Data = contro_on;
block.OutputPort(4).Data = [d_e;v_e]; 


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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function AcceptReqCall(Obj,events)
followerBlock = 'Example_SOMU_SYNC/Follower/Level-2 MATLAB S-Function';
followerBlockHandle = get_param(followerBlock,'Handle');  
figFollower = get_param(followerBlockHandle,'UserData');
figUDFollower = get(figFollower,'UserData');



leaderBlock = 'Example_SOMU_SYNC/Leader/Level-2 MATLAB S-Function';
leaderBlockHandle = get_param(leaderBlock,'Handle');
figLeader = get_param(leaderBlockHandle,'UserData');
figUDLeader = get(figLeader,'UserData');

follower_list = findobj(figLeader,'Tag','FollowerVehicle');
text1         = findobj(figLeader,'Tag','TextReq');

temp = strfind(text1.String,'join');

if ~isempty(find(temp{1}))

    global checkSignal;
    asdzxc = IDsSaving;

    idx = find(strcmp({asdzxc}, figUDFollower.IDs));

    if ~isempty(find(strcmp({asdzxc}, follower_list.String)))
        return
    end


    if ~isempty(length(figUDLeader.Nr))

        % follower_list.UserData = request_info.UserData(idx,:);
        Nr = length(figUDLeader.Nr);
        figUDLeader.Nr(Nr + 1) = Nr + 1; 
        figUDLeader.IDs(Nr + 1)      = {asdzxc};
        figUDLeader.vel(Nr + 1)      = figUDFollower.vel(idx);
        figUDLeader.dist(Nr + 1)     = figUDFollower.dist(idx);
        figUDLeader.accepted(Nr + 1) = 1;
        figUDLeader.declined(Nr + 1) = 0;


        figUDFollower.joinReq(idx)  = 0;


        follower_list.String{Nr + 1} = asdzxc;


        % if ~isempty(follower_list.String)
        %     follower_list.String = [follower_list.String,asdzxc];
        % else
        %     follower_list.String = {asdzxc};
        % end

        text1.String = '';

        checkSignal = 0;

        set(figFollower,'UserData',figUDFollower);
        set_param(followerBlockHandle,'UserData',figFollower);
        
        set(figLeader,'UserData',figUDLeader);
        set_param(leaderBlockHandle,'UserData',figLeader);
        return
    else
        Nr = 0;
        figUDLeader.Nr(Nr + 1) = Nr + 1; 
        figUDLeader.IDs(Nr + 1)      = {asdzxc};
        figUDLeader.vel(Nr + 1)      = figUDFollower.vel(idx);
        figUDLeader.dist(Nr + 1)     = figUDFollower.dist(idx);
        figUDLeader.accepted(Nr + 1) = 1;
        figUDLeader.declined(Nr + 1) = 0;


        figUDFollower.joinReq(idx)  = 0;


        follower_list.String{Nr + 1} = asdzxc;


        % if ~isempty(follower_list.String)
        %     follower_list.String = [follower_list.String,asdzxc];
        % else
        %     follower_list.String = {asdzxc};
        % end

        text1.String = '';

        checkSignal = 0;

        set(figFollower,'UserData',figUDFollower);
        set_param(followerBlockHandle,'UserData',figFollower);
        
        set(figLeader,'UserData',figUDLeader);
        set_param(leaderBlockHandle,'UserData',figLeader);
        return
    end
end



temp = strfind(text1.String,'leave');
if ~isempty(find(temp{1}))

    asdzxc = IDsSaving;
    followerVeh = get(follower_list,'UserData');

    idx = find(strcmp({asdzxc}, figUDLeader.IDs));

    asdqwe = 1:numel(figUDLeader.IDs);
    idx = find(asdqwe ~= idx);


    figUDLeader.Nr       = 1:length(idx); 
    figUDLeader.IDs      = figUDLeader.IDs(idx);
    figUDLeader.vel      = figUDLeader.vel(idx);
    figUDLeader.dist     = figUDLeader.dist(idx);
    % figUDLeader.accepted(Nr + 1) = 1;
    % figUDLeader.declined(Nr + 1) = 0;

    % idx123 = find(strcmp({asdzxc}, figUDFollower.IDs));
    % figUDFollower.leaveReq(idx123)  = 0;


    follower_list.String = follower_list.String(idx);

    text1.String = '';

    set(figFollower,'UserData',figUDFollower);
    set_param(followerBlockHandle,'UserData',figFollower);
    
    set(figLeader,'UserData',figUDLeader);
    set_param(leaderBlockHandle,'UserData',figLeader);
    return
end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%S
%%
function DeclineReqCall(Obj,events)
followerBlock = 'Example_SOMU_SYNC/Follower/Level-2 MATLAB S-Function';
followerBlockHandle = get_param(followerBlock,'Handle');  

figFollower = get_param(followerBlockHandle,'UserData');
figUDFollower = get(figFollower,'UserData');



leaderBlock = 'Example_SOMU_SYNC/Leader/Level-2 MATLAB S-Function';
leaderBlockHandle = get_param(leaderBlock,'Handle');
figLeader = get_param(leaderBlockHandle,'UserData');
figUDLeader = get(figLeader,'UserData');


asdzxc = IDsSaving;

idx = find(strcmp({asdzxc}, figUDFollower.IDs));

figUDFollower.joinReq(idx)  = 0;


text1         = findobj(figLeader,'Tag','TextReq');


text1.String = '';


set(figFollower,'UserData',figUDFollower);
set_param(followerBlockHandle,'UserData',figFollower);

set(figLeader,'UserData',figUDLeader);
set_param(leaderBlockHandle,'UserData',figLeader);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function FollowerVehiclesCall(Obj,events)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function [outputArg1] = IDsSaving(inputArg1)

persistent loser;
if nargin == 1
    loser = inputArg1;
    return
elseif nargin == 0
    outputArg1 = loser;
end