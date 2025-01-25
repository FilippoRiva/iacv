%% Introduction
clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');
load('s_h.mat')
load('h_rect.mat')
load('h_rect_vert.mat')

%% Q2_5
fprintf(1, "------------------------------------------\n>>                 Q2_5               <<\n------------------------------------------\n\n")

%% Compute points belonging to the conic
disp("Computing points...")
% Calculating error
im_err = zeros(size(img,1),size(img,2));
for i = 1:size(img,1)
    for j = 1:size(img,2)
        im_err(i,j) = [j,i,1]*S_h*[j;i;1];
    end
end

% Applying a threshold the conic and getting the pixel below that threshold
epsilon = 1e-5;
conic_mask = abs(im_err)<epsilon;

[y,x] = find(conic_mask==1);

A = [x,y];

% choosing 12 random points and projecting them into the vertical and horizontal plane
rng(42)
num_points = 12;
idxs = randperm(length(A));
res = zeros(num_points, 3);
res_h = zeros(num_points, 3);
res_v = zeros(num_points, 3);
for i = 1:num_points
    curr_idx = idxs(i);
    res(i,:) = [A(idxs(curr_idx),1), A(idxs(curr_idx),2),1];
    res_h(i,:) = H_rect * res(i,:)';
    res_h(i,:) = res_h(i,:)./res_h(i,3);
    res_v(i,:) = H_rect_vert * res(i,:)';
    res_v(i,:) = res_v(i,:)./res_v(i,3);
end
disp("> Done")

%% Showing results
fprintf(1,"\nShowing Results...\n")
format shortG
disp("> Original image points:")
disp(res(:,:))
disp("> Horizontal plane points:")
disp(double(res_h(:,:)))
disp("> Vertical plane points:")
disp(res_v(:,:))

disp("> Plotting ...")
% Calculating projected imgs
tform_h = projtform2d(H_rect);
img_h = imwarp(img, tform_h, "OutputView", imref2d(size(img)*10));
tform_v = projective2d(H_rect_vert');
[img_v, R_out_v] = imwarp(img, tform_v);

% Showing images and plotting chosen points
figure;
imshow(img)
hold on;
plot(res(:,1),res(:,2),'+')
xlim([min(res(:,1))-100,max(res(:,1))+100])
ylim([min(res(:,2))-100,max(res(:,2))+100])
title("Found points onto the original Image")

figure;
imshow(img_h)
hold on;
plot(res_h(:,1),res_h(:,2),'+')
xlim([min(res_h(:,1))-100,max(res_h(:,1))+100])
ylim([min(res_h(:,2))-100,max(res_h(:,2))+100])
title("Found points onto the horizontally rectified Image")

figure;
imshow(img_v, "XData", R_out_v.XWorldLimits, "YData", R_out_v.YWorldLimits)
hold on;
plot(res_v(:,1),res_v(:,2),'+')
xlim([min(res_v(:,1))-100,max(res_v(:,1))+100])
ylim([min(res_v(:,2))-100,max(res_v(:,2))+100])
title("Found points onto the vertically rectified Image")
disp(">> Done")

%% End
fprintf(1, "------------------------------------------\n>>             Q2_5 : END              <<\n------------------------------------------\n\n")