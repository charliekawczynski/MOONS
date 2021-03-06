clc; clear all; close all;

%% Origin of computations
% These results were obtained by running MOONS for BMC_1002 with and
% without conducting walls. After running these simulations, the pressure
% was observed, and the slope of the pressure was extracted to compare with
% the analytic 

%% Shercliff's Flow
% dpdx = (-4161.31+4061.85)/(6.00219-3.99897); % Non-uniform grid near wall
% dpdx = (-4145.63+4093.93)/(5.49968 - 4.50127); % Uniform grid near wall @
% 300,000 time steps
% dpdx = (-4150.24+4099.21)/(5.50194 - 4.49875); % Uniform grid near wall @ ~1M time steps
% dpdx = (1795.06-1886.78)/(20.8871-19.1091); % new but still running
% dpdx = (1795.45-1886.79)/(20.8863-19.1125);
% dpdx = (1797.31-1888.83)/(20.8895-19.1114);
% dpdx = (1967.86-2013.35)/(30.4427-29.5553); % Longer duct
dpdx = (2015.83-2061.19)/(30.441-29.5597);

% dpdx = -50.8; % Uniform grid near wall
Q_MOONS = -4/(10*dpdx);
Q_a = 7.68*10^-3;
percentError = abs(Q_MOONS-Q_a)/Q_a*100;
dpdx_exact = -4/(10*Q_a);

disp('--- Shercliff Flow (Ha = 500) ---')
disp(['Q_MOONS = ' num2str(Q_MOONS)])
disp(['Q_Analytic = ' num2str(Q_a)])
disp(['dp/dx_MOONS = ' num2str(dpdx)])
disp(['dp/dx_Analytic = ' num2str(dpdx_exact)])
disp(['Percent Error = ' num2str(percentError)])
disp(' ')

%% Hunt's Flow
% dpdx = (-4391.95+3834.16)/(5.9982-3.99609); % old
% dpdx = (5242.89-5747.66)/(20.8907-19.1119);
% dpdx = (5304.08-5808.47)/(20.8906-19.113);
dpdx = (5307.31-5812.05)/(20.8885-19.1097);
Q_MOONS = -4/(10*dpdx);
Q_a = 1.405*10^-3;
dpdx_exact = -4/(10*Q_a);
percentError = abs(Q_MOONS-Q_a)/Q_a*100;
disp('--- Hunt Flow (Ha = 500) ---')
disp(['Q_MOONS = ' num2str(Q_MOONS)])
disp(['Q_Analytic = ' num2str(Q_a)])
disp(['dp/dx_MOONS = ' num2str(dpdx)])
disp(['dp/dx_Analytic = ' num2str(dpdx_exact)])
disp(['Percent Error = ' num2str(percentError)])

