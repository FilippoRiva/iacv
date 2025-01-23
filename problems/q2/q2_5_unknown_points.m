clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');
load('s_h.mat')
load('h_rect.mat')
load('h_rect_vert.mat')

% Compute points that belong to the conic
im_err = zeros(size(img,1),size(img,2));
for i = 1:size(img,1)
    for j = 1:size(img,2)
        im_err(i,j) = [j,i,1]*S_h*[j;i;1];
    end
end

% thresholding the conic
epsilon = 1e-5;
conic_mask = abs(im_err)<epsilon;

[y,x] = find(conic_mask==1);

assert(conic_mask(y(1),x(1))==1)

A = [x,y];

% choosing 12 random points
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

% Showing results
format shortG
disp("Original image points:")
disp(res(:,:))
disp("Horizontal plane points:")
disp(double(res_h(:,:)))
disp("Vertical plane points:")
disp(res_v(:,:))

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

figure;
imshow(img_h)
hold on;
plot(res_h(:,1),res_h(:,2),'+')
xlim([min(res_h(:,1))-100,max(res_h(:,1))+100])
ylim([min(res_h(:,2))-100,max(res_h(:,2))+100])

figure;
imshow(img_v, "XData", R_out_v.XWorldLimits, "YData", R_out_v.YWorldLimits)
hold on;
plot(res_v(:,1),res_v(:,2),'+')
xlim([min(res_v(:,1))-100,max(res_v(:,1))+100])
ylim([min(res_v(:,2))-100,max(res_v(:,2))+100])