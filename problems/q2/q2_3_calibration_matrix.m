clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');

load('h_dir_avg.mat') % vanishing point of the h lines
load('l_dir_avg.mat') % vanishing point of the l lines
load('m_dir_avg.mat') % vanishing point of the m lines
load('h_rect.mat') % rectification matrix from original image to rectified img
load('hl_inf.mat') % image of the line at infinity


% omega will have the form : 
% [ a, 0, b ;
%   0, 1, c ;
%   b, c, d ]

syms a b c d 

omega = [a, 0, b; 
         0, 1, c;
         b, c, d];

% The constraints to obtain omega

% metric plane with known homography
H = inv(H_rect);
[h1, h2, h3] = deal(H(:,1), H(:,2), H(:,3));
eq1 = h1'*omega*h2 == 0;
eq2 = h1'*omega*h1 - h2'*omega*h2 == 0;

% using the perpendicularity constraints
% eq3 = h_dir_avg*omega*l_dir_avg' == 0;
% eq4 = h_dir_avg*omega*m_dir_avg' == 0;

% Using the line at infinity
eq34 = cross(hl_inf', omega*h_dir_avg') ==0; 
eq3 = eq34(1);
eq4 = eq34(2);

eqn = [eq1, eq2, eq3, eq4];

% Computing the solution and K
sol = solve(eqn, [a,b,c,d]);

omega = double([sol.a, 0, sol.b; 0, 1, sol.c; sol.b, sol.c, sol.d]);

omega_inv = inv(omega);
K = chol(omega_inv);

assert(norm(K'*K - omega_inv)<0.001, 'nope')

K = K./K(3,3);
pixel_ratio = K(1,1) / K(2,2);

save('./../../data/k.mat','K')
save('./../../data/omega.mat','omega')