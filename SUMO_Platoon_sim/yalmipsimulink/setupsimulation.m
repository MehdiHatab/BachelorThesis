% System
%Plant = ss(tf(1,[1 0 0]));
A = [0,0;1,0];
B = [1;0];
C = [0,1];
D = 0;

% Global sampling-time
Ts = 0.1;

% Initial state for simulation
x0 = [1;1];