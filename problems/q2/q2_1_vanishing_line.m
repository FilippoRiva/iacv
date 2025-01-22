clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

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



% calculates the insersection of two lines and returns the homogeneous point such that c=1
function res = calculateIntersectionFromIdx(idx1, idx2, lines)
    intersection = cross(lines(idx1).line, lines(idx2).line);
    res = intersection/intersection(3);
end



% Find the average of the intersection of all the combinations of m_i
range = 8:13;
comb = nchoosek(range, 2);
m_dir = zeros(length(comb), 3);
for i = 1:length(comb)
    m_dir(i,:) = calculateIntersectionFromIdx(comb(i,1),comb(i,2),lines);
end
m_dir_avg = [mean(m_dir(:,1)),mean(m_dir(:,2)),1];

% Find the average of the intersection between l1 & l3 + l2 & l3
l_dir = zeros(2, 3);
l_dir(1,:) = calculateIntersectionFromIdx(1,3,lines);
l_dir(2,:) = calculateIntersectionFromIdx(2,3,lines);
l_dir_avg = [mean(l_dir(:,1)),mean(l_dir(:,2)),1];





% show the resulting points at infinity and plot the line at infinity
f = figure;
imshow(img);
hold on;
plot_lines_from_struct(lines)
% plotting the m_dir points
for i = 1:15
    plot(m_dir(i,1),m_dir(i,2),'o');
end
plot(m_dir_avg(1),m_dir_avg(2),'+')
% plotting the l_dir points
for i = 1:2
    plot(l_dir(i,1),l_dir(i,2),'o');
end
plot(l_dir_avg(1),l_dir_avg(2),'+')
% plotting the line at infinity
xlim([0.5,3500.5])
ylim([0.5,1200.5])
xy = [m_dir_avg(1), m_dir_avg(2);
      l_dir_avg(1), l_dir_avg(2)];
plot(xy(:,1), xy(:,2),'LineWidth',2,'Color','blue'); 


% computing the line in homogeneous coordinates and storing it for future use
hl_inf = cross(m_dir_avg, l_dir_avg);

save('./../../data/hl_inf.mat', 'hl_inf')