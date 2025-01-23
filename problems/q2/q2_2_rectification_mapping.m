clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');
load('hl_inf.mat') % hl_inf is the horizontal plane line at infinity
load('c_h.mat') % csi_h is the homogeneous representation of the C circumference

R_img = imref2d(size(img), [0,size(img,2)], [0,size(img,1)]);

% Using a Stratified Rectification Methodology exploiting the C circuference
%% Affine Rectification 
% Building the H_affine

H_affine = [eye(2), zeros(2,1);hl_inf(:)'];
assert(norm(inv(H_affine)' * hl_inf' - [0; 0; 1]) < 0.000001, "The H_affine does not what it is supposed to do")

% Applying H_affine 
tform = projtform2d(H_affine);

disp("Calculating affine rectification results...")
outputX = [-200,16000];
outputY = [-200,10000];
R_out = imref2d([outputX(2)-outputX(1),outputY(2)-outputY(1)],outputX,outputY);
[img_aff, R_B] = imwarp(img, R_img ,tform, 'OutputView', R_out);

% Show affine rectification results
figure;
disp("Showing affine results...")
imshow(img_aff, "XData", R_B.XWorldLimits, "YData", R_B.YWorldLimits)
axis on


%% Metric Rectification

C = [eye(2), zeros(2,1); zeros(1,3)]; % C_inf canonical form

% Searching for the image of the conic dual to circular points
syms x y

[a, b, c, d, e, f] = deal(C_h(1,1), 2*C_h(1,2), C_h(2,2), 2*C_h(1,3), 2*C_h(2,3), C_h(3,3));

eq1 = a*x^2 + b*x*y + c*y^2 + d*x + e*y + f;
eq2 = hl_inf(1)*x + hl_inf(2)*y+ hl_inf(3);

eqns = [eq1 == 0, eq2 == 0];
S12 = solve(eqns, [x,y], 'IgnoreAnalyticConstraints',true,'Maxdegree',4);

% getting the two complex conjugate solutions
II = [double(S12.x(1)); double(S12.y(1)); 1];
JJ = [double(S12.x(2)); double(S12.y(2)); 1];

% Storing Circular Points
save('./../../data/ii.mat', 'II')
save('./../../data/jj.mat', 'JJ')

% Calculating image of the conic dual to circular points
imDCCP = II*JJ' + JJ*II'; 
save('./../../data/imDCCP.mat', 'imDCCP')

% Calculating the image of the C circumference
disp("Calculating transformed conic...")
Q = inv(H_affine)'*C_h*inv(H_affine);
Q = Q./Q(3,3);

% Show the result on the transformed image
% 
% SKIPPED : too much computation 
%
% disp("Plotting the tranformed conic...")
% plot_conic(Q, img_aff, "C") 

% Compute conic center
Q_2x2 = Q(1:2,1:2);
b = Q(1:2,3);
center = -Q_2x2 \ b;

% Computing axes and rotation
[V, D_eigen] = eig(Q_2x2);
lambda = diag(D_eigen);

axes = sqrt(abs(1 ./ lambda));
rotation = atan2(V(2, 1), V(1, 1));

% Rotation matrix
U = [cos(rotation), -sin(rotation); sin(rotation), cos(rotation)];
% rescaling the axis to be unitary
S = diag([1, axes(1)/axes(2)]);
K = U*S*U';
A = [K zeros(2,1); zeros(1,2),1];
H_rect = A*H_affine;

save('./../../data/h_rect.mat', 'H_rect')

tform = projtform2d(H_rect);

warning('off')
% Calculating results
disp("Calculating metric rectification results...")
outputX = [-1000,15000];
outputY = [-2000,11000];
R_out = imref2d([outputX(2)-outputX(1),outputY(2)-outputY(1)],outputX,outputY);
[img_rect, R_B] = imwarp(img, R_img ,tform, 'OutputView', R_out);
disp("Saving results...")
save('./../../data/img_rect.mat', 'img_rect')

% Showing metric rectification
disp("Showing results...")
figure;
imshow(img_rect, "XData", R_B.XWorldLimits, "YData", R_B.YWorldLimits)
axis on