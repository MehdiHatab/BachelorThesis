function sf2SENSOR_MODELS(block)
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

%% Function: setup ========================================================
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
block.NumInputPorts  = 9; %% <-- defines number of inputs (in SIMULINK)
block.NumOutputPorts = 2; %% <-- defines number of outputs (in SIMULINK)
block.NumDialogPrms  = 12; %% <-- defines number of arguments (in MASK)
%Dialog parameters ********************************************************
% (1)  NumObjects,
% (2)  MountX,
% (3)  MountY,
% (4)  MountA,
% (5)  SensorModel,
% (6)  SensorRange,
% (7)  SensorXY,
% (8)  SensorVisibility,
% (9)  SensorSegmentation,
% (10) SensorMinVis,
% (11) SensorType,
% (12) SensorAngle,

% OBJCET BUS **************************************************************
%1   flag_objects
%2   distx_objects
%3   disty_objects
%4   velx_objects
%5   vely_objects
%6   lane_objects
%7   lateraloffste_objects
%8   signal_objetcs
%9   width_objects

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

% set output port properties (object-matrix ... [properties x objects] )
block.OutputPort(1).Dimensions   = [9, NumberOfObjects];
block.OutputPort(1).DatatypeID   = 0; % double
block.OutputPort(1).Complexity   = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';

% set output port properties (object-matrix ... [properties x objects] )
NumSensors  = numel(block.DialogPrm(2).Data);
block.OutputPort(2).Dimensions   = [NumberOfObjects, NumSensors];
block.OutputPort(2).DatatypeID   = 0; % double
block.OutputPort(2).Complexity   = 'Real';
block.OutputPort(2).SamplingMode = 'Sample';

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [0.5, 0];

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
  % specify sampling times of input 
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
% allocate internal memory to later store precalculated model values for 
% RBF model type if this model type is chosen
% initialization takes place later!!

  % check which sensor model type is used
  SensorModel = block.DialogPrm(5).Data;     % either SECTOR (1) or RBF (2)
  
  switch SensorModel
      case 1, % SECTOR MODEL
          block.NumDworks = 1;                    % no preallocation needed
                                                  % only store the input
                                                  % flags over one sample
      case 2, % RBF MODEL
          NumSensors  = numel(block.DialogPrm(2).Data);  %
          
          % number of working variables
          block.NumDworks = NumSensors+1+1;       % allocate memory for 
                                                  % RBF-Model for each
                                                  % sensor + flags of input
          SensorXY        = block.DialogPrm(7).Data; % should be cell array

          % one array for each sensor model (may have different size)
          for iDwork=1:NumSensors
              if numel(SensorXY)>=iDwork
                  XSens = createSensorModel(SensorXY{iDwork},0);
                  NumberOfSensorPoints = size(XSens,2);
              else
                  NumberOfSensorPoints = 1;
              end
              block.Dwork(iDwork).Name    = sprintf('SensorData%u',iDwork);
              block.Dwork(iDwork).Dimensions      = 3*NumberOfSensorPoints;
              block.Dwork(iDwork).DatatypeID      = 0;      % double
              block.Dwork(iDwork).Complexity      = 'Real'; % real
              block.Dwork(iDwork).UsedAsDiscState = true;              
          end
          
          % one array for all smoothing factors
          block.Dwork(NumSensors+1).Name            = 'SensorSmoothing';
          block.Dwork(NumSensors+1).Dimensions      = NumSensors;
          block.Dwork(NumSensors+1).DatatypeID      = 0;      % double
          block.Dwork(NumSensors+1).Complexity      = 'Real'; % real
          block.Dwork(NumSensors+1).UsedAsDiscState = true;
  end
  
  NumberOfObjects = max(1,block.DialogPrm(1).Data);
  
  % allocate memory for flags to remember the status of detection from
  % pervios sample
  block.Dwork(block.NumDworks).Name            = 'object_flags';
  block.Dwork(block.NumDworks).Dimension       = NumberOfObjects;
  block.Dwork(block.NumDworks).DatatypeID      = 0;      % double
  block.Dwork(block.NumDworks).Complexity      = 'Real'; % real
  block.Dwork(block.NumDworks).UsedAsDiscState = true;

  
% end DoPostPropSetup
  
  
%%
%% InitializeConditions:
%%   Functionality   : Called at the start of simulation and if it is 
%%                     present in an enabled subsystem configured to reset 
%%                     states, it will be called when the enabled subsystem
%%                     restarts execution to reset the states.
%%   Required         : No
%%   C-MEX counterpart: mdlInitializeConditions
%%
function InitializeConditions(block)
  
  % initialize Dwork (used for RBF sensor model parameters)
  SensorModel = block.DialogPrm(5).Data;    % either SECTOR (1) or RBF (2)
  
  switch SensorModel
      case 1, % SECTOR MODEL     
          % nothing to be stored in advance
      case 2, % RBF MODEL
          % RBF models of sensors are fitted and parameters are stored for
          % faster execution afterwards
          
          NumSensors  = numel(block.DialogPrm(2).Data); % number of sensors
          
          SensorXY        = block.DialogPrm(7).Data; % should be cell array

          % create sensor model parameters and store them
          for iDwork=1:NumSensors
              % store the sensor fitpoints (RBF-model Parameters) and
              % weights
              if numel(SensorXY)>=iDwork     % defensive programmierung
                  [XSens,WSens,CSens] =createSensorModel(SensorXY{iDwork});
                  block.Dwork(iDwork).Data = [XSens(:);WSens(:)]; 
                  % stored values: X,Y,W
                  % Z coordinates are not needed only X,Y (input-space) and
                  % W (weights)
              end         
              % store all smoothing values in a seperate vector
              block.Dwork(NumSensors+1).Data(iDwork) = CSens;
          end
                    
  end
  
  % init the array storing the flag (status of an object)
  % (0=off,1=on,2=new)
  % since old input values are stored here init with zero
  NumberOfObjects = max(1,block.DialogPrm(1).Data);
  block.Dwork(block.NumDworks).Data = zeros(NumberOfObjects,1);
  
%end InitializeConditions


%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)
%% assign outputs
% for convinence
%% short cuts to mask parameters ------------------------------------------
NumObjects  = max(1,block.DialogPrm(1).Data);% size of object bus (vectors)
MountX      = block.DialogPrm(2).Data;      % x mounting pos of sensors
MountY      = block.DialogPrm(3).Data;      % y mounting pos of sensors
MountA      = block.DialogPrm(4).Data;      % mounting angle of sensors CCW
SensorModel = block.DialogPrm(5).Data;      % either SECTOR or RBF
SensorRange = block.DialogPrm(6).Data;      % sensor range if SECTOR
SensorVisibility   = block.DialogPrm(8).Data; % method for visibility
                                              % either segmentation or
                                              % cases
SensorSegmentation = block.DialogPrm(9).Data;  % number of segments
SensorMinVis       = block.DialogPrm(10).Data; % percentage of minimum 
                                               % visibility
SensorType  = block.DialogPrm(11).Data; % --> should be cell array
                                        % type of sensor
                                        % either 'C' for camera
                                        % 'R' for radar
                                        % 'L' for lidar
SensorAngle = block.DialogPrm(12).Data;      % sensor angle if SECTOR
%% traffic objects data from signal input ---------------------------------                                        
% object data from inputs                                        
object_distx = block.InputPort(2).Data'; 
object_disty = block.InputPort(3).Data';
object_width = block.InputPort(9).Data';
object_flag  = block.InputPort(1).Data';

%% output array -----------------------------------------------------------
% set all outputs savely to zero and overwrite later
d = block.OutputPort(1).Dimensions;
block.OutputPort(1).Data = zeros(d(1), d(2)); 

%% GENERAL ================================================================
% check consistency of GUI-inputs before! *********************************
% IMPROVE: Move into callbacks within mask for permanent changes

% MountX, MountY, MountA SensorType SensorMinVis should have same size
NumSensors = max([numel(MountX),numel(MountY),numel(MountA),...
                 numel(SensorType)]);
if NumSensors~=min([numel(MountX),numel(MountY),numel(MountA),...
                 numel(SensorType)]),
   %this should be catched in MASK             
   disp('SensorType and/or mounting have different sizes!');          
end
             
% depending on SensorModel SensorRange or SensorXY too
switch SensorModel,
    case 1, %'Sector Model',
        % set all not entered range values ot inf
        SensorRange(end+1:NumSensors)=inf;         
    case 2, %'RBF Model',
        % should happen in InitializeConditions AND DoPostPropSetup
    otherwise,    
        disp ('unsupported sensor-model-type selected !');
end
% depending on SensorVisibility SensorSegementation too
switch SensorVisibility,
    case 1, %'Cascaded case selection',        
    case 2, %'Segmentation',
        %SensorSegmentation(end+1:NumSensors)=10;
    otherwise
        disp('unsupported visibility algorithm selected!');
end
%%=========================================================================
% start with sensor evaluations
%
% allocate a object/sensor detection matrix *******************************
% this matrix stores which object is deteced by which sensor
% OSD is a matrix [ objects x sensors ]
OSD = zeros( NumObjects, NumSensors );

% first of all a lot of object related data is generated which is later 
% needed for calculating visibility/shadowing
% (all this is calculated within the sector model)
[OSD_Sector, dist, deltaSens, gammaSens, delta_Obj, gamma_Obj] = ...
    check_SECTOR_SENSOR_MODELS( OSD, MountX, MountY, MountA,...
                                SensorRange, SensorAngle, object_width,...
                                SensorMinVis, object_distx, object_disty );

%% PERFORM MODEL DEPENDENT SENSOR DETECTION ===============================
% tell if an object is detected by a sensor without taking into account
% visibility/masking (i.e. each object if it is alone)
switch SensorModel,
    case 1, %'Sector Model',
        % the sensor model is taking into account the objects width and
        % possible partly seen objects.
        % the object model is therefore a circle.
        % note: this object model leads to possible detection of objects
        % having a center outside the sensor sector, if the width of the
        % object is within the sensor sector and the parameter controlling
        % the detection of partly seen objects is small enought
        OSD = OSD_Sector;            % reuse already calculated secor model    
    case 2, %'RBF Model',
        % NOTE that the RBF-model checks if the object reference point lies
        % in the detection area or not.
        % NOTE this means the object is reduced to one point.
        % NOTE It can be interpreted with a fixed 50% visibility detection 
        % value and a object model with variable width
        OSD = check_RBF_SENSOR_MODELS( OSD, MountX, MountY, MountA, ...
                                       block, ...
                                       object_distx, object_disty );
       % for visibility checking the assumtion in this case is that the
       % full objects angles are taken.
       % note that for the sector model it is possible to use potentially
       % reduced object angles, if objects partially are outside the sensor
       % sector
       deltaSens = delta_Obj;
       gammaSens = gamma_Obj;
    otherwise,    
        disp ('unsupported sensor-model-type selected !');
end
    

%% PERFORM VISIBILITY DETECTION ===========================================
% two different algorithms can be selected in the mask
switch SensorVisibility,
    case 1, %'Cascaded case selection',
        OSD = check_CASCADED_CASE_MODEL(OSD, dist, deltaSens, gammaSens,...
                                        SensorMinVis, delta_Obj-gamma_Obj);
        % only one (the biggest) part of the visible part of an object is
        % taken
    case 2, %'Segmentation',
        OSD = check_SEGMENTAION_MODEL( OSD, dist, deltaSens, gammaSens,...
                                       SensorMinVis, SensorSegmentation );
        % the object is segemented in a number of pices defined in the mask
        % the visibility of partly hidden objects is calculated by counting
        % seen segments, which is more detailed than the first algorithm
    otherwise
        disp('unsupported visibility algorithm selected!');
end

%% reset ObjectSensorDetection matrix for inactive objects ================
% switch off all objects that are inactive 
OSD(object_flag==0,:)=0;

%% "fuse" sensor detection
% make an index of objects which have been detected by at least one sensor
fusedDetection = any(OSD,2)';

%--------------------------------------------------------------
% flag (0..off, 1..active, 2..new)
    % set flags of not detected objects to zero
    object_flag( ~fusedDetection )    = 0;
    
    object_flag_old = block.Dwork(block.NumDworks).Data;
    
    %                    oldflag
    %               0     1     2
    %          0    0     0     0    --> nothing to do (new==0 is always 0)
    % newflag  1    2     1     1    --> change to 2 if new==1 and old==0
    %          2    2     2     2    --> nothing to do (new==2 is always 2)
    %
    object_flag( object_flag == 1 & ~object_flag_old') = 2;
    
    block.OutputPort(1).Data(1,:)     = object_flag;  % set output
    block.Dwork(block.NumDworks).Data = object_flag'; % store for next step
    detected = zeros(1,length(object_flag));
    detected(find(object_flag)) = ones(1,length(find(object_flag)));
% dist x
    % just transfer data from input to output (no change in xdist now)
    % IMPROVE: add sensor accuracy/noise here
    block.OutputPort(1).Data(2,:) = object_distx.*detected;
    
% dist y
    % just transfer data from input to output (no change in ydist now)
    % IMPROVE: add sensor accuracy/noise here
    block.OutputPort(1).Data(3,:) = object_disty.*detected;
    
% vel x
    % just transfer data from input to output (no change in xvel)
    % IMPROVE: add sensor accuracy/noise here
    block.OutputPort(1).Data(4,:) = block.InputPort(4).Data'.*detected;
    
% vel y
    % just transfer data from input to output (no change in yvel)
    % IMPROVE: add sensor accuracy/noise here
    block.OutputPort(1).Data(5,:) = block.InputPort(5).Data'.*detected;
    
% lane
    % just transfer data from input to output (no change in lane)
    % IMPROVE: add sensor accuracy/noise here
    block.OutputPort(1).Data(6,:) = block.InputPort(6).Data'.*detected;
    
% lateraloffset
    % just transfer data from input to output (no change in offset)
    % IMPROVE: add sensor accuracy/noise here
    block.OutputPort(1).Data(7,:) = block.InputPort(7).Data'.*detected;
    
% brake signal
    % signals are only transmitted if one camera sees the object    
    block.OutputPort(1).Data(8,:) = checkForSignalDetectability(...
                                               block.InputPort(8).Data',...
                                               OSD, SensorType);
    
% objects width
    % just transfer data from input to output (no change in width)
    % IMPROVE: add sensor accuracy/noise here
    block.OutputPort(1).Data(9,:) = object_width.*detected;
    
% additional info port showing which object is seen by which sensor    
    block.OutputPort(2).Data = OSD;

%end Outputs
%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)
  %disp(['[OK]']);

%end Terminate

%%*************************************************************************
function [OSD, dist, deltaSens, gammaSens, delta_Obj, gamma_Obj] = ...
         check_SECTOR_SENSOR_MODELS( OSD, MountX, MountY, MountA,...
                                     SensorRange, SensorAngle, ...
                                     widthObj, SensorMinVis, distx, disty )
                                 
% This function calculates some object model parameters which are important 
% for evaluation of visibility
% Main task of this function is to tell if an object is seen by one of the
% sector model sensors defined in the mask
% NOTE THIS MODEL IS LIMITED TO 180� DETECTION RANGE !  (exception is 360�)

    % transform object coordinates into sensor coordinates to make things
    % straight forward to calculate
    % (I):shift to mount point, (II):rotate in sensor orientation
    [distx_,disty_] = transform_VEH_TO_SENSOR_CCS( MountX, MountY, ...
                                                   MountA,...
                                                   distx, disty );
                                               
     [NumObj, NumSens] = size(OSD); 
                                               
     %[alpha,dist,beta,gamma,delta,bAngl,xB,yB,xC,yC,e] = ...
     %                                        deal(zeros(NumObj, NumSens));
     
     %calc some angular object model parameters (see docu)
     sensAngle = repmat(SensorAngle,NumObj,1).*pi./180;
     sensRange = repmat(SensorRange,NumObj,1);
     
     disty = disty_';
     distx = distx_';
     % calc distance
     dist          = sqrt(distx.^2+disty.^2);
     % check if objects are in range of sensors
     DetectedRange = dist <= sensRange;
          
     % calc angle of center for all objects in all sensor coordinate sys
     alpha_Obj  = atan2(disty,distx);  % always ---> -pi<= alpha <= pi 
     
     
     % for point object (width =0) check absolute angle of center only
     % NOTE THIS MODEL IS NOT LIMITED IN DETECTION ANGLE
     % THIS SIMPLE MODEL IS VALID FOR 0� to 360�
     %DetectedAngle = abs(alpha_Obj)<= sensAngle/2;
     %Detected = DetectedRange & DetectedAngle;
     %OSD( Detected ) = 1;
             
     % GEOMETRIC MODEL USING WIDTH 
     % NOTE THIS IS LIMITED TO 180� DETECTION RANGE !  (exception is 360�)
     % (NOTE FOR RATHER BROAD OBJECTS NEAR RANGE AND BIG DETECTION ANGLES
     % OBJECTS MAY BE DETECTED FULLY ALTHOUGH PARTLY OUTSIDE OF RANGE)
     
     width_Obj  = repmat(widthObj', 1, NumSens);
     beta_Obj   = atan( 0.5 * width_Obj ./ dist );
     gamma_Obj  = alpha_Obj - beta_Obj;
     delta_Obj  = alpha_Obj + beta_Obj;
          
     % dist to corners
     % distCorners_Obj = sqrt( 0.25.*width_Obj.^2 + distx.^2+disty.^2 );     

     % set really fully detected objects to '1'
     detectionCase_FullyDetected = ...
          ( sensAngle/2 >= abs(delta_Obj) & ...
            sensAngle/2 >= abs(gamma_Obj) & ...
            DetectedRange); %distCorners_Obj <= sensRange ); 
     OSD( detectionCase_FullyDetected ) = 1;
     
     % cover partly dected cases 
     deltaSens = delta_Obj;
     gammaSens = gamma_Obj;

     detectionAngleMin = -sensAngle/2;
     detectionAngleMax = +sensAngle/2;
     
     if any( SensorAngle(:)>180 & SensorAngle(:)<360) &&  any(widthObj(:)) 
        disp(['Sector sensor model is not applicable for',...
              '180�<angles<360� and width<>0 !']); 
     end
     
     
     % change the angles of the object model (make them smaller) if object
     % partly is outside the sensor
     idx = gammaSens < detectionAngleMin;
     gammaSens( idx ) = detectionAngleMin( idx ); 
     idx = deltaSens > detectionAngleMax;     
     deltaSens( idx ) = detectionAngleMax( idx );
     
     % set angles to 0 if totally outside the sensor
     idx = deltaSens < detectionAngleMin | gammaSens > detectionAngleMax;
     deltaSens( idx ) = 0;
     gammaSens( idx ) = 0;
     
     % calculate the seen part
     widthAngl  = 2.*beta_Obj;     
     objFractionDetected = (deltaSens - gammaSens)./widthAngl;
         
     OSD( objFractionDetected >= (SensorMinVis*0.01) &...
          dist <= sensRange ) = 1;
     
     %% deal with 360� Sensors (exeption)
     for idx = find(SensorAngle==360)
         OSD ( DetectedRange(:,idx),idx ) = 1;
         deltaSens(DetectedRange(:,idx),idx) = ...
             delta_Obj(DetectedRange(:,idx),idx);
         gammaSens(DetectedRange(:,idx),idx) = ...
             gamma_Obj(DetectedRange(:,idx),idx);
     end
                                              
%end SECTOR MODEL *********************************************************

%%*************************************************************************
function OSD = check_RBF_SENSOR_MODELS( OSD, MountX, MountY, MountA, ...
                                        block, distx, disty )
% This is the main function of the radial basis function sensor model

    % transform object coordinates into sensor coordinates to make things
    % straight forward to calculate
    % (I):shift to mount point, (II):rotate in sensor orientation
    [distx_,disty_] = transform_VEH_TO_SENSOR_CCS( MountX, MountY, ...
                                                   MountA,...
                                                   distx, disty );     
     NumSens  = size(OSD,2); % number of sensors
            
     for iDwork=1:NumSens                                 % for all sensors
        SParam =  block.Dwork(iDwork).Data;            % get the parameters
        numSensPoints = block.Dwork(iDwork).Dimension/3;
        XSens = reshape(SParam(1:2*numSensPoints),2,[]); % X;Y  2 x points
        WSens = SParam(2*numSensPoints+1:end);           % W    points x 1
        c     = block.Dwork(NumSens+1).Data(iDwork); 
        
        % check visibility
        Detected = RBFeval( [distx_(iDwork,:);disty_(iDwork,:)],...
                            XSens, WSens, c );
        
        % use a sharp detection rule >1
        % this means if the center is in, the object is detected
        % otherwise its not detected
        % NOTE: this implies a 50% visibility compaired to a object model
        % with a variable width
        % IMPROVE since the sensor has a smooth behaviour (3D surface)
        % there are possibilities to account for partly seen objects         
        OSD( Detected>1, iDwork ) = 1;
        
     end                                                                     
                                               
%end RBF MODEL ************************************************************

%%*************************************************************************
function OSD = check_CASCADED_CASE_MODEL( OSD, dist, deltaS, gammaS,...
                                          SensorMinVis, object_widthAngle)
    NumSens                = size(OSD,2);               % number of sensors
    
    for iSens=1:NumSens                      % check all sensors seperately
        OSD_thisSensor = OSD(:,iSens);    % extract object/sensor detection
        
        if sum(OSD_thisSensor)>=2,              % case of 2 or more objects
                                      % --> potentially one hides the other
            
            idxSeenObj       = find(OSD_thisSensor);    % index of detected
            [~, DecendIndex] = sort( dist(idxSeenObj,iSens),'descend');
            objToCheck   = idxSeenObj(DecendIndex);  % idx objects to check
            
            for i_objCheck = 1:numel(objToCheck)-1     % check all but last
                
                for i_objFront = i_objCheck+1:numel(objToCheck)
                    
                %**********************************************************
                % distinguish 4 cases which lead to (partly hidden objects)
                % case 5 (no overlapping) doesnt need to be considered
                    
                    iOF = objToCheck(i_objFront);
                    iOC = objToCheck(i_objCheck);
                    if OSD(iOC,iSens) ~= 0,
                        % case 1 "object is totally hidden" 
                        if  deltaS(iOF,iSens) >= deltaS(iOC,iSens)...
                                && gammaS(iOF,iSens) <= gammaS(iOC,iSens),
                            % totally hidden
                            deltaS(iOC, iSens) = 0;
                            gammaS(iOC, iSens) = 0;
                            
                        % case 2 "object is partly hidden left"
                        elseif deltaS(iOF,iSens)>gammaS(iOC,iSens)...
                                && deltaS(iOF,iSens)<deltaS(iOC,iSens)...
                                && gammaS(iOF,iSens)<gammaS(iOC,iSens),
                            % hidden between gamma(iOC) and delta(iOF)
                            gammaS(iOC,iSens) = deltaS(iOF,iSens);
                            
                            % case 3 "object is partly hidden right"
                        elseif deltaS(iOF,iSens)>deltaS(iOC,iSens)...
                                && gammaS(iOF,iSens)>gammaS(iOC,iSens)...
                                && gammaS(iOF,iSens)<deltaS(iOC,iSens),
                            % hidden between gamma(iOC) und delta(iOF)
                            deltaS(iOC,iSens) = gammaS(iOF,iSens);
                            
                            % case 4 "object is partly hidden in middle"
                        elseif deltaS(iOF,iSens)<deltaS(iOC,iSens)...
                                && gammaS(iOF,iSens)>gammaS(iOC,iSens),
                            % hidden between gamma(iOC) und delta(iOC)
                            
                            visAngLeft  = deltaS(iOC,iSens) - ...
                                deltaS(iOF,iSens);
                            visAngRight = gammaS(iOF,iSens) - ...
                                gammaS(iOC,iSens);
                            if visAngLeft >= visAngRight,
                                gammaS(iOC,iSens)= deltaS(iOF,iSens);
                            else
                                deltaS(iOC,iSens)= gammaS(iOF,iSens);
                            end
                        end % end if cases
                        
                        f = (deltaS(iOC,iSens)-gammaS(iOC,iSens))...
                            /object_widthAngle(iOC, iSens);
                        
                        if f <= SensorMinVis*0.01,
                            OSD(iOC,iSens) = 0;
                        end
                    end
                end % for all objects in front
                
            end % for all objects potentially hidden            
            
        end % if there are potentially hidden objects
    end % for all sensors

%end CASCADED CASE MODEL **************************************************

%%*************************************************************************
function OSD = check_SEGMENTAION_MODEL( OSD, dist, deltaS, gammaS,...
                                        SensorMinVis, SensorSegments )

    NumSens                = size(OSD,2);               % number of sensors
    
    for iSens=1:NumSens                      % check all sensors seperately
        OSD_thisSensor = OSD(:,iSens);    % extract object/sensor detection
        
        if sum(OSD_thisSensor)>=2,              % case of 2 or more objects
                                      % --> potentially one hides the other
            
            idxSeenObj       = find(OSD_thisSensor);    % index of detected
            [~, DecendIndex] = sort( dist(idxSeenObj,iSens),'descend');
            objToCheck   = idxSeenObj(DecendIndex);  % idx objects to check
            objVisible   = false(size(objToCheck));  % all are hidden 
            objVisible(end) = true;                   % nearest is unhidden
            
            for i_objCheck = 1:numel(objToCheck)-1     % check all but last
                
                % create a vector of segements which are 
                SegThisObj = linspace( ...
                    gammaS(objToCheck(i_objCheck),iSens),...
                    deltaS(objToCheck(i_objCheck),iSens),...
                    SensorSegments+1);
                SegIsVisible = true(size(SegThisObj));
                for i_objHide = i_objCheck+1:numel(objToCheck)
                    isHidden = ...
                     gammaS(objToCheck(i_objHide),iSens)<=SegThisObj &...
                     deltaS(objToCheck(i_objHide),iSens)>=SegThisObj;
                    SegIsVisible(isHidden) = 0;
                end
                
                % decide if fraction of partly covered object is still
                % enough to be detected properly
                % TODO: add a minimum angle-resolution for detection
                if (sum(SegIsVisible)/SensorSegments) >= SensorMinVis*0.01,
                    objVisible(i_objCheck) = true;
                end
            end % for all objects potentially hidden
            
            % reset all detected objects which are not visible
            OSD( objToCheck(~objVisible) , iSens ) = 0;
        end  % if there are potentially hidden objects
    end % for all sensors
                                                   
%end SEGMENTATION MODEL ***************************************************

%%*************************************************************************
function [distx_,disty_] = transform_VEH_TO_SENSOR_CCS( MountX, MountY,...
                                                        MountA,...
                                                        distx, disty )
  nSens = numel(MountX);
  nObj  = numel(distx);
  distx_ = zeros( nSens, nObj );
  disty_ = zeros( nSens, nObj );
  R     = zeros(2,2);
    
  for iSens=1:nSens   % for each sensor process all objects
      % calculate rotation matrix for rotated sensor cordinate system
      angleRad = MountA(iSens)*pi/180;
      R(:,:) = [  cos(angleRad), sin(angleRad);...
                 -sin(angleRad), cos(angleRad) ];
      % translate object coordinates in car system to sensor system
      X = R*([distx;disty] - repmat([MountX(iSens);...
                                     MountY(iSens)],1,nObj));
      
      % store values for output
      distx_( iSens, : ) = X(1,:);
      disty_( iSens, : ) = X(2,:);
  end
    
%end transform_VEH_TO_SENSOR_CCS

%%*************************************************************************
function [XSensor,WSensor,SmoothnessSensor] = ...
                                      createSensorModel(SensorDefinition,~)
%helper function for RBF-Model

  % Get Sensor Data
  [XSensor,ZSensor] = getSensorShape(SensorDefinition);
  % Define smoothness factor (kernel smoothness)
  SmoothnessSensor = 1/12;
  % Define smoothing factor (regularization parameter)
  % 0 -> points are met exact
  lam  = 0.001;
  if nargin==1,
    % calculate the weights (no linear terms since 0 outside data is wanted)
    WSensor = RBFweights( XSensor, ZSensor, SmoothnessSensor, lam );
  else 
    WSensor=0; 
  end
% end createSensorModel

%%*************************************************************************
function [XSensor,ZSensor] = getSensorShape(SensorDefinition)
%helper function for RBF-Model  SensorDefinition ... [2xn]

% duplicate points (symmetric to x-axis)
dup = SensorDefinition(2,:)~=0; % dont dublicate points on axis
SensorDefinition = [   SensorDefinition, ...
                       [ fliplr(SensorDefinition(1,dup)); ...
                         fliplr(-SensorDefinition(2,dup))]          ];

% number of sensor area point on the border
nbrData = size(SensorDefinition,2);
% add z coordinate on border (z=1)
coord3d = [SensorDefinition;ones(1,nbrData)];
% calculate center of gravity of all datapoints (simple mean)
mu = mean(coord3d([1,2],:), 2);
% calc connection vectors from center to each point
dmux = SensorDefinition - repmat(mu,1,nbrData);
% inner fitting points (are at level z=2)
inner   = repmat(mu,1,nbrData) + 0.7*dmux; % factor 0.7 -> sharpness inside
coord3d = [coord3d, [inner;2*ones(1,nbrData)]];
% outer fitting points (are at level z=0)
outer   = repmat(mu,1,nbrData) + 1.5*dmux; % factor 1.5 -> sharpness ouside
coord3d = [coord3d, [outer;0*ones(1,nbrData)]]; 
%
XSensor = coord3d(1:2,:);
ZSensor = coord3d(3,:);
% end getSensorShape

%%*************************************************************************
function WSensor = RBFweights( XSensor, ZSensor, SmoothnessSensor, lam )
%helper function for RBF-Model
  N     = size(XSensor,2);
  phi   = zeros(N,N);
  for i = 1:N
    phi(i,i+1:end) = RBFPhi( XSensor(:,i), XSensor(:,i+1:end), ....
                             SmoothnessSensor );
  end
  phi = phi + phi' + eye(N);
  
  WSensor = ( phi'*phi + lam*eye(size(phi,1)) )\(phi'*ZSensor');
% end RBFweights

%%*************************************************************************
function phi = RBFPhi( XObj, XSensor, SmoothnessSensor )
%helper function for RBF-Model
   nc = size(XSensor,2);
   for xIdx = 1:size( XObj, 2 )
      r  = repmat(XObj(:,xIdx),1,nc) - XSensor;
      r2 = sum(r.*r,1);
      phi(xIdx,:) = RBFcalc(r2, SmoothnessSensor);
   end
%end RBFPhi

%%*************************************************************************
function rbf = RBFcalc(r2, c)
%helper function for RBF-Model
    rbf = exp(-r2*c*c);
%end RBFcalc

%%*************************************************************************
function ZObj = RBFeval( XObj, XSensor, WeightsSensor, SmoothnessSensor )
%helper function for RBF-Model
   phi = RBFPhi( XObj, XSensor, SmoothnessSensor);
   ZObj  = phi*WeightsSensor;
%end RBFeval

%%*************************************************************************
function sig = checkForSignalDetectability(sigExist, OSD, sensType)
% dependent on sensor type object signals are deleted
% (camera sensor sees brake-lights, radar does not)
%
%NOTE this function currently does not distinguish the type of signal
% --> all signals are either transmitted or not depending on the sensor
% type and detection
% IMPROVE: distinguish signals and possibly object heading

  % set all signals to zero
  sigDetected = sigExist.*0;
  for iSens=1:numel(sensType)
      switch sensType{iSens}
          case 'R',
              % do nothing
          case 'L',
              % do nothing
          case 'C',
              % add detection if sensor is camera AND signal exits
              sigDetected = sigDetected | ( OSD(:,iSens)' & sigExist );
          otherwise
        disp('not supported sensor type in checkForSignalDetectability()');
      end
  end
  
  % allocate empty space for all signals
  sig = zeros(1,numel(sigExist));
  % transfer all detected signal values
  if any(sigDetected),
      sig(sigDetected) = sigExist(sigDetected);
  end
%end checkForSignalDetectability
