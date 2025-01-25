%% Initialization
clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');
load('hl_inf.mat') % hl_inf is the horizontal plane line at infinity
load('c_h.mat') % csi_h is the homogeneous representation of the C circumference

R_img = imref2d(size(img), [0,size(img,2)], [0,size(img,1)]);

fprintf(1, "------------------------------------------\n>>                 Q2_2                 <<\n------------------------------------------\n\n")

% Using a Stratified Rectification Methodology exploiting the C circuference
%% Affine Rectification 

disp("Calculating affine rectification...")
% Building the H_affine using the line at infinity
H_affine = [eye(2), zeros(2,1);hl_inf(:)'];
assert(norm(inv(H_affine)' * hl_inf' - [0; 0; 1]) < 0.000001, "The H_affine does not what it is supposed to do")

% Applying H_affine 
tform = projtform2d(H_affine);
disp("> Done")

% Show affine rectification results
fprintf(1,"\nShowing affine results...\n")

outputX = [-200,16000];
outputY = [-200,10000];
R_out = imref2d([outputX(2)-outputX(1),outputY(2)-outputY(1)],outputX,outputY);
[img_aff, R_B] = imwarp(img, R_img ,tform, 'OutputView', R_out);

figure;

imshow(img_aff, "XData", R_B.XWorldLimits, "YData", R_B.YWorldLimits)
axis on
disp("> Done")


%% Calculating the image of the conic dual to circular points

fprintf(1,"\nCalculating the image of the conic dual to circular points...\n")

% Searching for the image of the conic dual to circular points
syms x y

[a, b, c, d, e, f] = deal(C_h(1,1), 2*C_h(1,2), C_h(2,2), 2*C_h(1,3), 2*C_h(2,3), C_h(3,3));

% Intersecting the known conic with the line at infinity
eq1 = a*x^2 + b*x*y + c*y^2 + d*x + e*y + f;
eq2 = hl_inf(1)*x + hl_inf(2)*y+ hl_inf(3);

eqns = [eq1 == 0, eq2 == 0];
S12 = solve(eqns, [x,y], 'IgnoreAnalyticConstraints',true,'Maxdegree',4);

% getting the circular points
II = [double(S12.x(1)); double(S12.y(1)); 1];
JJ = [double(S12.x(2)); double(S12.y(2)); 1];

% Calculating image of the conic dual to circular points
imDCCP = II*JJ' + JJ*II'; 
disp("> Done")

%% Calculating the rectifying homography

fprintf(1,"\nCalculating the rectifying homography...\n")
% Calculating the image of the C circumference
Q = inv(H_affine)'*C_h*inv(H_affine);
Q = Q./Q(3,3);

% Compute conic center
Q_2x2 = Q(1:2,1:2);
b = Q(1:2,3);
center = -Q_2x2 \ b;

% Computing axes and rotation
[V, D_eigen] = eig(Q_2x2);
lambda = diag(D_eigen);

axes = sqrt(abs(1 ./ lambda));
rotation = atan2(V(2, 1), V(1, 1));
U = [cos(rotation), -sin(rotation); sin(rotation), cos(rotation)];

% rescaling the axis to be unitary
S = diag([1, axes(1)/axes(2)]);
K = U*S*U';
A = [K zeros(2,1); zeros(1,2),1];
H_rect = A*H_affine;
disp("> Done")


%% Plotting the result
tform = projtform2d(H_rect);
warning('off')
% Calculating results
fprintf(1,"\nPlotting metric rectification results...\n")
outputX = [-1000,15000];
outputY = [-2000,11000];
R_out = imref2d([outputX(2)-outputX(1),outputY(2)-outputY(1)],outputX,outputY);
[img_rect, R_B] = imwarp(img, R_img ,tform, 'OutputView', R_out);

% Showing metric rectification
figure;
imshow(img_rect, "XData", R_B.XWorldLimits, "YData", R_B.YWorldLimits)
axis on
disp("> Done")

%% Storing Results
fprintf(1,"\nStoring results...\n")
save('./../../data/h_rect.mat', 'H_rect')
disp("> Done")

%% End
fprintf(1, "------------------------------------------\n>>             Q2_2 : END               <<\n------------------------------------------\n\n")