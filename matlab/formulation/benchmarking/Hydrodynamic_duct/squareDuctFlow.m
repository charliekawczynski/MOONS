% Clear workspace and prescribe path
clear;clc;close all;
p = mfilename('fullpath');
[thisDir,name,ext] = fileparts(p);
chdir(thisDir); format short
% ***************************************
%% Analytic solution of flow in a square duct
% This solution was found in 
%
% 1. Kashaninejad, N., Chan, W. K. & Nguyen, N. Analytical and Numerical
% Investigations of the Effects of Microchannel Aspect Ratio on Velocity 
% Profile and Friction Factor. 1�9 (2012).

w = 1;
h = 1;
M = 100; N = 100;
I = 100; J = 100;
x = linspace(0,2*w,I);
y = linspace(0,2*h,J);
u = zeros(I,J);
alpha = w/h;
F = 100;

% Fortran format
% for j=1:J
%     for i=1:I
%         for m=1:M
%             for n=1:N
%                 A1 = 16*F*alpha^2*h^2/((m*pi)^2+(alpha*n*pi)^2);
%                 A2 = 1/(m*pi)*1/(n*pi);
%                 A3 = (1-cos(m*pi))*(1-cos(n*pi));
%                 A = A1*A2*A3;
%                 u(i,j) = u(i,j) + A*sin(m*pi*x(i)/(2*w))*sin(n*pi*y(j)/(2*h));
%             end
%         end
%     end
% end

% Matlab vectorized format
for m=1:M
    for n=1:N
        A1 = 16*F*alpha^2*h^2/((m*pi)^2+(alpha*n*pi)^2);
        A2 = 1/(m*pi)*1/(n*pi);
        A3 = (1-cos(m*pi))*(1-cos(n*pi));
        A = A1.*A2.*A3;
        u = u + A*sin(m.*pi*x/(2*w))'*sin(n.*pi*y/(2*h));
    end
end


[X Y] = meshgrid(x,y);

surf(X,Y,u')
title(['Fully Developed Square Duct Flow (exact), F = ' F])
xlabel('x')
ylabel('y')
zlabel('u(x,y)')

