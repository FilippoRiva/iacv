%% Initialization
clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

format shortG

% loading the lines struct
load('lines.mat');
% lines struct :
%   - point1 : the first detected point
%   - point2 : the second detected point
%   - name : the name of the line (according to the assignment)
%   - line : in homogeneous coordinates

% This is how the points are ordered in the array struct
%   name : [l1,l2,l3,h1,h2,h3,h4,m1,m2,m3,m4,m5,m6]
%   idxs : [1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,11,12,13]

% loading the img
img = imread('img.jpg');


%% Q2_1
fprintf(1, "------------------------------------------\n>>                 Q2_1                 <<\n------------------------------------------\n\n")

%% Computing Vanishing Points

% Find the average of the intersection of all the combinations of m_i
disp("Computing vanishing point of the m lines ...")
range = 8:13;
comb = nchoosek(range, 2);
m_dir = zeros(length(comb), 3);
for i = 1:length(comb)
    m_dir(i,:) = calculate_intersection_from_idx(comb(i,1),comb(i,2),lines);
end
m_vp = [mean(m_dir(:,1)),mean(m_dir(:,2)),1];
disp("> Solution:")
disp(m_vp)

% Find the average of the intersection between l1 & l3 + l2 & l3
fprintf(1, '\nComputing vanishing point of the l lines ...\n')
l_dir = zeros(2, 3);
l_dir(1,:) = calculate_intersection_from_idx(1,3,lines);
l_dir(2,:) = calculate_intersection_from_idx(2,3,lines);
l_vp = [mean(l_dir(:,1)),mean(l_dir(:,2)),1];
disp("> Solution:")
disp(l_vp)

% Find the average of the intersection of all the combinations of h_i
% Calculated here for future use
fprintf(1, '\nComputing vanishing point of the h lines ...\n')
range = 4:7;
comb = nchoosek(range, 2);
h_dir = zeros(length(comb), 3);
for i = 1:length(comb)
    h_dir(i,:) = calculate_intersection_from_idx(comb(i,1),comb(i,2),lines);
end
h_vp = [mean(h_dir(:,1)),mean(h_dir(:,2)),1];
disp("> Solution:")
disp(h_vp)


%% Plotting results
% show the resulting points at infinity and plot the line at infinity
fprintf(1, '\nPlotting the results ...\n')
f = figure;
imshow(img);
hold on;
plot_lines_from_struct(lines)
% plotting the m_dir points
for i = 1:15
    plot(m_dir(i,1),m_dir(i,2),'o');
end
plot(m_vp(1),m_vp(2),'+')
% plotting the l_dir points
for i = 1:2
    plot(l_dir(i,1),l_dir(i,2),'o');
end
plot(l_vp(1),l_vp(2),'+')
% plotting the line at infinity
xlim([0.5,3500.5])
ylim([0.5,1200.5])
xy = [m_vp(1), m_vp(2);
      l_vp(1), l_vp(2)];
plot(xy(:,1), xy(:,2),'LineWidth',2,'Color','blue'); 
title("Horizontal vanishing line")

disp("> Done")

%% Computing the vanishing line
% computing the line in homogeneous coordinates and storing it for future use
fprintf(1, '\nComputing the vanishing line...\n')
hl_inf = cross(m_vp, l_vp);
hl_inf = hl_inf / (hl_inf(3));
disp('> Result:')
disp(hl_inf)

%% Storing results
save('./../../data/m_vp.mat', 'm_vp')
save('./../../data/l_vp.mat', 'l_vp')
save('./../../data/h_vp.mat', 'h_vp')
save('./../../data/hl_inf.mat', 'hl_inf')

%% End
fprintf(1, "------------------------------------------\n>>             Q2_1 : END               <<\n------------------------------------------\n\n")