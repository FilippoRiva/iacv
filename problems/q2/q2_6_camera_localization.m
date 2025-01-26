%% Initialization
clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

format shortG

img = imread('img.jpg');

load('points.mat') % points : the matrix that contains the 4 corners of the rectified frontal panel in homogeneous coordinates
load('actual_height.mat') % actual_height :the actual heigth computed in q2_4
load('actual_depth.mat') % actual_height :the actual heigth computed in q2_4
load('lines.mat')
load('h_rect.mat')
load('k.mat') % K : calibration matrix calculated in q2_3

%% Q2_6
fprintf(1, "------------------------------------------\n>>                 Q2_6               <<\n------------------------------------------\n\n")

%% Getting world to plane homography
disp("Computing world to plane homography...")
SCALE = 1000;
width = 1 * SCALE;
heigth = actual_height * SCALE;
points = points(:,1:2);

real_points = [ % same order as the points variable
    0,  heigth,;     %upper left corner
    0,  0;          %lower left corner
    width, 0;       %lower right corner
    width, heigth;  %upper right corner
];

tform = fitgeotform2d(points, real_points, 'projective');
[img_plane, R_out_plane] = imwarp(img, tform);

H_img_to_plane = tform.T.';

H_plane_to_img = inv(H_img_to_plane);
disp("> H_plane_to_img:")
disp(H_plane_to_img)


%% Obtaining Rotation and Translation from the homography
fprintf(1, "\nComputing rotation and translation...\n")

% getting r1 r2 and t from the K^-1 H relation for the pi plane (z=0)
B = K \ H_plane_to_img;
B = B / norm(B(:,1));

rx = B(:,1);
ry = B(:,2);
rz = cross(rx,ry);
t = B(:,3);

% Fixing R to be a rotation matrix (imposing orthogonality and unit determinant)
R = [rx, ry, rz];

[U, ~, V] = svd(R);
R = U * V';

% Building the P projection matrix
P = [K'*R, K'*t];

% Obtain center knowing that RNS(Mm) = c
c = null(P);
c = c/c(4);

% Results
pos = c(1:3);
rot = R;

disp('> Full projection matrix:')
disp(P)
disp('> Camera rotation matrix:')
disp(rot)
disp('> Camera position:')
disp(pos)

%% Storing Results
fprintf(1, "\nStoring results...\n")
save('./../../data/h_plane_to_img.mat','H_plane_to_img')
save('./../../data/p.mat','P')
save('./../../data/rot.mat','rot')
save('./../../data/pos.mat','pos')
disp("> Done")

%% End
fprintf(1, "------------------------------------------\n>>             Q2_6 : END              <<\n------------------------------------------\n\n")