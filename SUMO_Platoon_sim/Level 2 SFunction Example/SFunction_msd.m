function SFunction_msd(block)

% Example of a Mass Spring Damper System by means of a level-2 Matlab 
% S-Function in order to use functions such as
%   1) loading an *.xml file to obtain the system parameters and 
%   2) the usage of Matlab structures
% 
% The program loads the system parameters by using the MassSpringDamper.xml
% file and stores the parameters inside a Matlab structure by using the
% Xml2Struct.m file.
% 
% Reference of the Xml2Struct.m file:
% https://nl.mathworks.com/matlabcentral/fileexchange/28518-xml2struct
% 
% The Mass Spring Damper System is solved by using a state-space approach
% as described in:
% 
% Heylen, W., S. Lammens, and P. Sas. Modal Analysis Theory and Testing,
% (Katholieke Universiteit Leuven, Departement Werktuigkunde). 
% ISBN 90-73802-61-X, 1997, Pages A.1.12 and A.1.13


% IMPORTANT NOTES: 
% ----------------
% 
% 1) In order to make the model work, be sure your Matlab path is correctly
%    set (pointing to the donwloaded folder). 
% 2) You can also use absolute path/file names instead of the relative one 
%    in the constant block.


% Author:  Laurent Keersmaekers
% Date:    21/11/2018
% Company: Van Hool NV

  setup(block);
  
%endfunction

function setup(block)
  % MyStruct is defined as a global parameter in order to use it in the
  % Output(block) function
  global MyStruct; 
  MyStruct                                = []; % be sure MyStruct is empty
  
  %% Register number of input and output ports
  block.NumInputPorts                     = 3;
  block.NumOutputPorts                    = 1;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions           = 2;
  block.InputPort(1).DatatypeID           = 0;  % double
  block.InputPort(1).Complexity           = 'Real';
  block.InputPort(1).DirectFeedthrough    = true;
  block.InputPort(1).SamplingMode         = 'Sample';
  
  block.InputPort(2).Dimensions           = 500;
  block.InputPort(2).DatatypeID           = 3;  % uint8
  block.InputPort(2).DirectFeedthrough    = true;
  block.InputPort(2).SamplingMode         = 'Sample';
  
  block.InputPort(3).Dimensions           = 1;
  block.InputPort(3).DatatypeID           = 0;  % double
  block.InputPort(3).Complexity           = 'Real';
  block.InputPort(3).DirectFeedthrough    = true;
  block.InputPort(3).SamplingMode         = 'Sample';
  
  block.OutputPort(1).Dimensions          = 2;
  block.OutputPort(1).DatatypeID          = 0; % double
  block.OutputPort(1).Complexity          = 'Real';
  block.OutputPort(1).SamplingMode        = 'Sample';
  
  %% Set block sample time to inherited
  block.SampleTimes                       = [-1 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance                = 'DefaultSimState';

  %% Run accelerator on TLC
  block.SetAccelRunOnTLC(true);
  
  %% Register methods
  block.RegBlockMethod('Outputs',                 @Output);  
  
%endfunction

function Output(block)
  global MyStruct;
  
  if ~isstruct(MyStruct) % Load the *.xml file only once
    
    txt               = char(block.InputPort(2).Data);
    File              = strtrim(txt.');
    
    MyStruct          = Xml2Struct(...
                          File);
  end
  
  q                                       = block.InputPort(1).Data;        % [x; v] in [[m]; [m/s]]
  F                                       = block.InputPort(3).Data;        % [N]
  
  m                                       = MyStruct.SystemParameters.m;    % [kg]
  c                                       = MyStruct.SystemParameters.c;    % [Ns/m]
  k                                       = MyStruct.SystemParameters.k;    % [N/m]
  
  A                                       = [c m ;
                                             m 0];
  
  B                                       = [k  0 ;
                                             0 -m];
  
  % Differential equations to be solved:
  % m*d²x/dt² + c*dx/dt + k*x = F(t)
  % 
  % or:
  % 
  % m*dv/dt + c*dx/dt + k*x = F(t)
  % 
  % State space representation with states x and v:
  % 
  % m*dv/dt + c*dx/dt + k*x = F(t), and
  % m*dx/dt - m*dx/dt = 0
  % 
  % or in matrix notation:
  % 
  % [m c] * [dx/dt] + [k  0] * [x] = [F]
  % [0 m]   [dv/dt]   [0 -m]   [v]   [0]
  % 
  % or:
  % A*dq/dt + B*q = F'
  % 
  % The system is solved as follows:
  % 
  % dq/dt = A\(F' - B*q)
  
  dq                                      = A\([F; 0] - B*q);
  
  block.OutputPort(1).Data                = dq;
  
%endfunction

