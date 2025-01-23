clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');

load('h_dir_avg.mat') % h_dir_avg : vanishing point of the h lines
load('l_dir_avg.mat') % l_dir_avg : vanishing point of the l lines
load('omega.mat') % omega : absolute conic


% calculating the line at infinity of the vertical plane
vl_inf = cross(h_dir_avg, l_dir_avg);
vl_inf = vl_inf ./ vl_inf(3);

% Finding the Circular Points for the vertical plane as the intersection between omega and vl_inf
syms x y 

I = [x;y;1];

eq1 = omega(1,1) * x^2 + 2*omega(1,2)*x*y + omega(2,2) * y^2 + 2*omega(1,3)*x+2*omega(2,3)*y+omega(3,3)==0;
eq2 = vl_inf(1) * x + vl_inf(2) * y + vl_inf(3) == 0;
  
sol = solve([eq1, eq2], [x,y]);

II = double([sol.x(1); sol.y(1); 1]);
JJ = double([sol.x(2); sol.y(2); 1]);

% Computing the conic dual to the circular points and finding the rectifying homography
imDCCP = II*JJ' + JJ*II'; 
imDCCP = imDCCP./norm(imDCCP);

[U,S,V] = svd(imDCCP);
S(3,3) = 1;
H_rect_vert = inv(U * sqrt(S));

tform = projective2d(H_rect_vert');

% Showing the results
img_rect = imwarp(img, tform);

figure;
imshow(img_rect)
hold on;
impixelinfo

% Picking points by hand 
ul = [3394.5;
      2510.0];
ll = [3722.5;
      2330.0];
lr = [2670.5;
      1030.5];

points = [ul';ll';lr';];

% Calculating distances and showing final result
height = norm(ul - ll);
width = norm(lr - ll);
actual_height = 1/width*height;
disp(actual_height)

plot(points(1:2,1), points(1:2,2), 'LineWidth', 2,'Color','blue')
avg = (ul + ll) / 2;
text(avg(1),avg(2), sprintf('%.4f',actual_height))
plot(points(2:3,1), points(2:3,2), 'LineWidth', 2,'Color','red')
avg = (ll + lr) / 2;
text(avg(1),avg(2), '1')
