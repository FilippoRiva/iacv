clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');

load('h_dir_avg.mat') % h_dir_avg : vanishing point of the h lines
load('l_dir_avg.mat') % l_dir_avg : vanishing point of the l lines
load('lines') % lines : struct defined in q1_2
load('h_rect.mat')

load('omega.mat') % omega : absolute conic


% ---- Functions ------

function norm_line = normalize(line)
      norm_line = line ./ line(3);
end


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

% Storing the results for future use
save('./../../data/h_rect_vert.mat','H_rect_vert')

tform = projective2d(H_rect_vert');

% Calculating corners in the original image
l2 = get_line_by_name('l2', lines);
l3 = get_line_by_name('l3', lines);
h1 = get_line_by_name('h1', lines);
h4 = get_line_by_name('h4', lines);

borders = [l2; l3; h1; h4];

for i = 1:4
      borders(i,:) = normalize(borders(i,:));
end

ul = cross(borders(2,:), borders(3,:));
ll = cross(borders(1,:), borders(3,:));
lr = cross(borders(1,:), borders(4,:));
ur = cross(borders(2,:), borders(4,:));

points = [ul; ll; lr; ur];

for idx = 1:4
      points(idx,:) = normalize(points(idx,:));
end

save('./../../data/points.mat', "points")

% Calculating points in the rectified image
for idx = 1:4
      points(idx,:) = H_rect_vert*points(idx,:)' ;
      points(idx,:) = normalize(points(idx,:));
end

% Calculating distances 
height = norm(points(1,:) - points(2,:));
width = norm(points(3,:) - points(2,:));
actual_height = 1/width*height;
disp('heigth to width ratio :')
disp(actual_height)
save('./../../data/actual_height.mat', 'actual_height')


% Calculating lower corners in the original image
l1 = get_line_by_name('l1', lines);
l2 = get_line_by_name('l2', lines);
m5 = get_line_by_name('m5', lines);
m6 = get_line_by_name('m6', lines);

borders = [l1; l2; m5; m6];

for i = 1:4
      borders(i,:) = normalize(borders(i,:));
end

ul = cross(borders(2,:), borders(3,:));
ll = cross(borders(1,:), borders(3,:));
lr = cross(borders(1,:), borders(4,:));
ur = cross(borders(2,:), borders(4,:));

points = [ul; ll; lr; ur];

% Calculating points in the rectified image
for idx = 1:4
      points(idx,:) = normalize(points(idx,:));
      points(idx,:) = H_rect*points(idx,:)' ;
      points(idx,:) = normalize(points(idx,:));
end

% Calculating depth 
width = norm(points(1,:) - points(4,:));
depth = norm(points(1,:) - points(2,:));
actual_depth = 1/width*depth;
disp('depth to width ratio :')
disp(actual_depth)
save('./../../data/actual_depth.mat', 'actual_depth')

% Showing the results (only for the heigth)
[img_rect, R_out] = imwarp(img, tform);

figure;
imshow(img_rect, "XData", R_out.XWorldLimits, "YData", R_out.YWorldLimits)
hold on;
axis on;

plot(points(1:2,1), points(1:2,2), 'LineWidth', 2,'Color','blue')
avg = (points(1,:) + points(2,:)) / 2;
text(avg(1),avg(2), sprintf('%.4f',actual_height))
plot(points(2:3,1), points(2:3,2), 'LineWidth', 2,'Color','red')
avg = (points(2,:) + points(3,:)) / 2;
text(avg(1),avg(2), '1')
