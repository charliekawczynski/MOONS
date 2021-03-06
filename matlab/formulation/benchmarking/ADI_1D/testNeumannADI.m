%% ***************************************
% Clear workspace and prescribe path
clear;clc;close all;
p = mfilename('fullpath');
[thisDir,name,ext] = fileparts(p);
chdir(thisDir); myDir.this = thisDir;

%% PARAMS
% n = 2^7; % Number of cells
n = 20; % Number of cells
neumann = true; % (true,false) = (f=cose(), f = sin()) and with appropriate BCs
Nsweeps = 100; % Number of multi-scale sweeps / ordinary sweeps
p = 1*4; % Fourier Mode, look at p = 1 for neumann: looks bad
nlevels = floor(log2(n));
tol = 1e-6; % stopping tolerance
dt = 0.1;
solveInterior = true;
multiScale = true;
alpha = 1;

%% Grid generation (c for coordinates)
c.hn = linspace(0,1,n+1);                   % Node grid
c.dhn = c.hn(2) - c.hn(1);                  % dh for node grid
c.hc = [(c.hn(1)-c.dhn/2) (c.hn+c.dhn/2)];  % CC grid
c.dhc = c.hc(2) - c.hc(1);                  % dh for CC grid

u_bcs.type = 3; u_bcs.val = zeros(2,1);


%% PROBLEM SETUP
a = modelProblem();
if (neumann)
    u_solution = cos(p*pi*c.hn)';
    u_solution = u_solution - mean(u_solution);
    f = lap(a,u_solution,alpha,c.dhn);

    if (solveInterior)
        f = applyBCs(a,f,u_bcs,c.hn);
        a.neumannInterior(c.hn,u_solution,f,u_bcs,alpha,n,Nsweeps,nlevels,dt,multiScale);
    else
        f(1) = alpha*(-u_solution(1)+u_solution(2))/c.dhn^2;
        f(end) = alpha*(-u_solution(end)+u_solution(end-1))/c.dhn^2;
        a.neumannTotal(c.hn,u_solution,f,alpha,n,Nsweeps,nlevels,dt,multiScale);
    end
else
    u_solution = sin(2*p*pi*c.hn)';
    f = lap(a,u_solution,alpha,c.dhn);
    f(1) = u_solution(1); f(end) = u_solution(end);
    a.dirichlet(c.hn,u_solution,f,alpha,n,Nsweeps,nlevels,dt,multiScale);
end



