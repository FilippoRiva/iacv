
clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

load('rot.mat')
load('pos.mat')
load('actual_height.mat')
load('actual_depth.mat')
load('omega.mat')

% Plotting
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
text(100,100, 0, 'LETSGOSKY','Color','w', 'FontSize',20)

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


