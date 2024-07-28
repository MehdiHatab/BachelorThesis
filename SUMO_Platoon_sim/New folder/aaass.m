clc, clear all, close all

numOfObj = 5;
Td = 0.5;
kp = 0.1859;
kd = 0.7021;

A = [0,1;0,0];
b = [0;1];
B = [b,-b];

cT = [1,0];

C = eye(2);

D = zeros(2,2);
sysd = c2d(ss(A,b,cT,0),Td);

Ad = sysd.A;
bd = sysd.B;
cTd = sysd.C;

Q = diag([1E3,0.1]);
% R = diag([1,100]);
R = 1000;
% K = lqr(A,B,Q,R);

kT = acker(Ad,bd,[0.8,0.6]);
% kT = lqr(Ad,bd,Q,R);
% kT = K(2,:);

% V = -1./([1,0]*inv(A-B*K)*B)';

V = 1./(cT*inv(eye*(2) - Ad+bd*kT)*bd);