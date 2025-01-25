%% Initialization
clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');

load('h_rect_vert.mat')
load('s_h.mat')

load('rot.mat')
load('pos.mat')
load('actual_height.mat')
load('actual_depth.mat')
load('omega.mat')

%% Q3_1
fprintf(1, "------------------------------------------\n>>                 Q3_1                 <<\n------------------------------------------\n\n")

%% Computing the rectified curve S
disp("Rectifying S...")
H_inv = inv(H_rect_vert);
S_prime = H_inv'*S_h*H_inv;
disp("> S_prime :")
disp(S_prime)

% Showing the results
fprintf(1,'Showing rectified curve\n')
% Defining a region of interest to compute conic points for
ROI = [-600, -1300;
       -200, -1000];
ROI_size = [ ROI(2,2)-ROI(1,2),ROI(2,1)- ROI(1,1)];
min_x = min(ROI(:,1));
min_y = min(ROI(:,2));

% Computing conic points
im_err = zeros(ROI_size(1),ROI_size(2));
offx = abs(min_x)+1; % x offset of a coordinate in the matrix wrt our reference frame
offy = abs(min_y)+1; % y offset of a coordinate in the matrix wrt our reference frame
for x = ROI(1,1):ROI(2,1)
    for y = ROI(1,2):ROI(2,2)
        i = x+offx;
        j = y+offy;
        im_err(j,i) = [x,y,1]*S_prime*[x;y;1];
    end
end
    
% thresholding the conic and computing a mask
epsilon = 5e-5;
conic_mask = abs(im_err)<epsilon;


tform = projective2d(H_rect_vert');
[rect_img, R_out] = imwarp(img, tform);

tx = abs(R_out.XWorldLimits(1));
ty = abs(R_out.YWorldLimits(1));
rect = [ROI(1,1) + tx, ROI(1,2) + ty, ROI_size(2), ROI_size(1)];

rect_img = imcrop(rect_img, rect);

img_rgb(:, :, 1) = rect_img(:, :, 1) + uint8(255 * conic_mask); % Red channel
img_rgb(:, :, 2) = rect_img(:, :, 2) .* uint8(~conic_mask);     % Remove green
img_rgb(:, :, 3) = rect_img(:, :, 3) .* uint8(~conic_mask);     % Remove blue

figure;
imshow(img_rgb)
hold on;
axis on;
disp("> Done")

%% 3D Plotting
fprintf(1,'\n3D Plotting...\n')
SCALE = 1000;
WIDTH = 1 * SCALE;
HEIGTH = actual_height * SCALE;
DEPTH = actual_depth * SCALE;

figure();
front = [
    0,      0,      0; 
    0,      HEIGTH, 0; 
    WIDTH,  HEIGTH, 0
    WIDTH,  0,      0; 
    ];


back = [
    0,      0,      -DEPTH;
    WIDTH,  0,      -DEPTH;
    0,      HEIGTH, -DEPTH;
    WIDTH,  HEIGTH, -DEPTH;
];

hold on;

fill3(front(:,1),front(:,2),front(:,3),'b')

pcshow(pointCloud(front), "MarkerSize", 800)
pcshow(pointCloud(back), "MarkerSize", 800)

plotCamera('location', pos, 'orientation', rot.', 'size', 20)

xlabel('X')
ylabel('Y')
zlabel('Z')
xlim([-500,1100])
ylim([-200,300])
zlim([-400,800])

grid on
disp("> Done")

%% End
fprintf(1, "------------------------------------------\n>>             Q3_1 : END               <<\n------------------------------------------\n\n")