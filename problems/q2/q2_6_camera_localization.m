%% Initialization
clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

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

real_points = [
    0,  heigth; %ul
    0,  0; %ll
    width, 0; %lr
    width, heigth; %ur
];

tform = fitgeotform2d(points, real_points, 'projective');
[img_w, R_out_w] = imwarp(img, tform);

H_img_to_w = tform.T.';

H_w_to_img = inv(H_img_to_w);
disp("> H_w_to_img:")
disp(H_w_to_img)


%% Obtaining Rotation and Translation from the homography
% Getting the Rotation and Translation
fprintf(1, "\nComputing rotation and translation...\n")
h1 = H_w_to_img(:,1);
h2 = H_w_to_img(:,2);
h3 = H_w_to_img(:,3);

lambda = 1/norm(K\h1);

r1 = (K \ h1) * lambda;
r2 = (K \ h2) * lambda;
r3 = cross(r1,r2);

R = [r1,r2,r3];

[U, ~, V] = svd(R);
R = U * V';

T = (K \(lambda * h3));

rot = R.';
pos = -R.' * T;

disp('> Camera rotation matrix:')
disp(rot)
disp('> Camera position:')
disp(pos)

%% Storing Results
fprintf(1, "\nStoring results...\n")
save('./../../data/rot.mat','rot')
save('./../../data/pos.mat','pos')
disp("> Done")

%% End
fprintf(1, "------------------------------------------\n>>             Q2_6 : END              <<\n------------------------------------------\n\n")