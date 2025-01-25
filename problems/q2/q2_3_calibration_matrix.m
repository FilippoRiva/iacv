%% Initialization
clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');

load('h_dir_avg.mat') % h_dir_avg : vanishing point of the h lines
load('l_dir_avg.mat') % l_dir_avg : vanishing point of the l lines
load('m_dir_avg.mat') % m_dir_avg : vanishing point of the m lines
load('h_rect.mat') % H_rect : rectification matrix from original image to rectified img
load('hl_inf.mat') % hl_inf : image of the line at infinity


%% Q2_3
fprintf(1, "------------------------------------------\n>>                 Q2_3               <<\n------------------------------------------\n\n")

%% Calculating omega (IAC)
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

% Using the line at infinity
eq34 = cross(hl_inf', omega*h_dir_avg') ==0; 
eq3 = eq34(1);
eq4 = eq34(2);

eqn = [eq1, eq2, eq3, eq4];

% Computing the solution and K
fprintf(1, 'Solving the linear system for omega ...\n')
sol = solve(eqn, [a,b,c,d]);

omega = double([sol.a, 0, sol.b; 0, 1, sol.c; sol.b, sol.c, sol.d]);
disp("> Derived Omega matrix (a.k.a. image of the absolute conic):")
disp(omega)

%% Computing Calibration 
fprintf(1, '\nComputing Calibration through Cholesky Factorization ...\n')
omega_inv = inv(omega);
K_chol = chol(omega_inv);
assert(norm(K_chol'*K_chol - omega_inv) < 0.001, 'Cholesky Failure');

K_chol = K_chol./K_chol(3,3);
pixel_ratio = K_chol(1,1) / K_chol(2,2);

disp("> Calibration using Cholesky Factorization (note the non-0 skew factor):")
disp(K_chol)


fprintf(1, '\nComputing Calibration through iac to calibration known relations ...\n')
alfa = sqrt(omega(1, 1));
u0 = -omega(1, 3) / (alfa^2);
v0 = -omega(2, 3);
fy = sqrt(omega(3, 3) - (alfa^2) * (u0^2) - (v0^2));
fx = fy / alfa;
K = [fx, 0, u0;  0, fy, v0;  0, 0, 1];

disp("> Calibration forcing the skew to 0:")
disp(K)


%% Storing results
fprintf(1, '\nStoring 0-skew calibration matrix ...\n')
save('./../../data/k.mat','K');
save('./../../data/omega.mat','omega');
disp("> Done")

%% End
fprintf(1, "------------------------------------------\n>>             Q2_3 : END              <<\n------------------------------------------\n\n")