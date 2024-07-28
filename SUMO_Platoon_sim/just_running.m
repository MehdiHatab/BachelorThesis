clc, close all, clear all, clear classes

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

SumoTs = 0.5;
EgoName = {'veh0'};
NumVehicles = 10;
SumoCfg = 'data1\line.sumocfg';
% SumoCfg = 'data1\hokkaido.sumocfg';
SumoIP = '127.0.0.1';
SumoPort = 8873;
SumoGui = 1;
SumoOptions = '';
NumTLights = 0;
SensorRange = 200;


% global PlatoonGUI;
% global FollowerGUI;
% PlatoonGUI   = leader_Obj;
% FollowerGUI  = SUMO_Obj;


A = [0,1;0,0];
b = [0;1];
B = [b,-b];

cT = [1,0];

C = eye(2);

D = zeros(2,2);
sysd = c2d(ss(A,b,cT,0),SumoTs);

Ad = sysd.A;
bd = sysd.B;
cTd = sysd.C;

Q = diag([1,100]);
% R = diag([1,100]);
R = 1;
% K = lqr(A,B,Q,R);

s1 = -5;
s2 = -6;

z1 = 1/(1-SumoTs*s1);
z2 = 1/(1-SumoTs*s2);
% kT = acker(Ad,bd,[z1,z2]);
% kT = acker(A,b,[s1,s2]);
kT = lqrd(A,b,Q,R,SumoTs);
% kT = lqr(A,b,Q,R);
% kT = dlqr(Ad,bd,Q,R);
% kT = K(2,:);

% V = -1./([1,0]*inv(A-B*K)*B)';
V = -1./(cT*inv(A-b*kT)*b);
% V = 1./(cT*inv(eye*(2) - Ad+bd*kT)*bd);


