function uout = MPCController(currentx,currentr,t)

persistent Controller

if t == 0
    % Compute discrete-time dynamics
    %Plant = ss(tf(1,[1 0 0]));
    plant = ss(tf([1],[1,0]));
    A = plant.A;
    B = plant.B;
    C = plant.C;
%     A = [0,1;0,0];
%     B = [0;1];
%     C = [0,1];
    [nx,nu] = size(B);
    Ts = 0.5;
    Gd = c2d(ss(A,B,C,0),Ts);
    Ad = Gd.A;
    Bd = Gd.B;
    
    
    % Define data for MPC controller
    N = 10;
    Q = 10;
    R = 1000;
    
    % Avoid explosion of internally defined variables in YALMIP
    yalmip('clear')
    
    % Setup the optimization problem
    u = sdpvar(repmat(nu,1,N),repmat(1,1,N));
    x = sdpvar(repmat(nx,1,N+1),repmat(1,1,N+1));
    sdpvar r
    % Define simple standard MPC controller
    % Current state is known so we replace this
    constraints = [];
    objective = 0;
    for k = 1:N
        objective = objective + (r-C*x{k})'*Q*(r-C*x{k})+u{k}'*R*u{k};
        constraints = [constraints, x{k+1} == Ad*x{k}+Bd*u{k}];
        constraints = [constraints, -1 <= u{k}<= 1];
    end
    
    % Define an optimizer object which solves the problem for a particular
    % initial state and reference
    Controller = optimizer(constraints,objective,[],{x{1},r},u{1});
    
    % And use it here too
    uout = Controller(currentx,currentr);
    
else    
    % Almost no overhead
    uout = Controller(currentx,currentr);
end