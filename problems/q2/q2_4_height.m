%% Initialization
clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');

load('h_vp.mat') % h_vp : vanishing point of the h lines
load('l_vp.mat') % l_vp : vanishing point of the l lines
load('lines') % lines : struct defined in q1_2
load('h_rect.mat')

load('omega.mat') % omega : absolute conic

%% Q2_4
fprintf(1, "------------------------------------------\n>>                 Q2_4               <<\n------------------------------------------\n\n")

%% Functions

function norm_line = normalize(line)
      norm_line = line ./ line(3);
end


%% Finding circular points of the vertical plane and computing their dual conic
disp("Computing circular points and imDCCP...")
% calculating the line at infinity of the vertical plane
vl_inf = cross(h_vp, l_vp);
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
disp("> Done")

%% Getting the rectifying homography from the original image
fprintf(1,'\nGetting rectifying homography\n')
[U,S,V] = svd(imDCCP);
S(3,3) = 1;
H_rect_vert = inv(U * sqrt(S));

tform = projective2d(H_rect_vert');
disp("> H_rect_vert:")
disp(H_rect_vert)

%% Computing Heigth
fprintf(1,'\nComputing Heigth...\n')
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

hpoints = [ul; ll; lr; ur];

for idx = 1:4
      hpoints(idx,:) = normalize(hpoints(idx,:));
end

points = hpoints;
save('./../../data/points.mat', "points")

% Calculating points in the rectified image
for idx = 1:4
      hpoints(idx,:) = H_rect_vert*hpoints(idx,:)' ;
      hpoints(idx,:) = normalize(hpoints(idx,:));
end

% Calculating distances 
height = norm(hpoints(1,:) - hpoints(2,:));
width = norm(hpoints(3,:) - hpoints(2,:));
actual_height = 1/width*height;
disp('> Heigth to width ratio :')
disp(actual_height)
save('./../../data/actual_height.mat', 'actual_height')


%% Showing heigth results
[img_rect, R_out] = imwarp(img, tform);

figure;
imshow(img_rect, "XData", R_out.XWorldLimits, "YData", R_out.YWorldLimits)
hold on;
axis on;

plot(hpoints(1:2,1), hpoints(1:2,2), 'LineWidth', 2,'Color','blue')
avg = (hpoints(1,:) + hpoints(2,:)) / 2;
text(avg(1),avg(2), sprintf('%.4f',actual_height))
plot(hpoints(2:3,1), hpoints(2:3,2), 'LineWidth', 2,'Color','red')
avg = (hpoints(2,:) + hpoints(3,:)) / 2;
text(avg(1),avg(2), '1')

%% Storing results
save('./../../data/h_rect_vert.mat','H_rect_vert')
save('./../../data/vl_inf.mat','vl_inf')

fprintf(1, "------------------------------------------\n>>             Q2_4 : END              <<\n------------------------------------------\n\n")