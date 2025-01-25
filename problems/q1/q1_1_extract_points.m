%% Initialization
clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

% Load the image
img = imread('img.jpg');

%% Q1_1
fprintf(1, "------------------------------------------\n>>                 Q1_1                 <<\n------------------------------------------\n\n")

%% Preprocessing
% Image Preprocessing for C
gray = rgb2gray(img); 
grayImg1= imadjust(gray);
grayImg1= histeq(grayImg1);
grayImg1 = imgaussfilt(grayImg1, 2);

% Image Preprocessing for S
grayImg2 = imgaussfilt(gray, 1);
grayImg2 = edge (grayImg2, 'Canny');

%% Harris Features Detection
disp("Detecting Features using Harris Features Detection...")

% Regions for circumference C and S
x1 = 410; y1 = 505; x2 = 744; y2 = 600;
C_ROI = [x1, y1, x2 - x1, y2 - y1];
x1 = 824; y1 = 491; x2 = 958; y2 = 547;
S_ROI = [x1, y1, x2 - x1, y2 - y1];


% Parameters for Harris Features detection
minquality1 = 0.0005;
minquality2 = 0.001;
filterSize1 = 3;
filterSize2 = 3;

% Perform Harris corner detection with the current filter size
harrisPoints1 = detectHarrisFeatures(grayImg1, 'MinQuality', 0.0005, 'FilterSize', filterSize1, 'ROI', S_ROI).selectStrongest(200);
harrisPoints2 = detectHarrisFeatures(grayImg2, 'MinQuality', 0.001, 'FilterSize', filterSize2, 'ROI', C_ROI).selectStrongest(500);
disp("> Features Detected")


%% Manual Point Selection from Detected Harris Features
% Plotting and Manual Points Selection
figure;

try 
    load('S.mat')
    fprintf(1, "\nSkipping Manual selection of S : already found in /data folder...\n")
    disp("> Loaded S points :")
    disp(S)
catch
    disp("Select Points using the Brush tool")
    % S selection
    imshow(img);
    hold on;
    plot(harrisPoints1);
    axis([S_ROI(1), S_ROI(1)+S_ROI(3), S_ROI(2), S_ROI(2)+S_ROI(4)])
    title('Select the S curve points, right click, Export Brushed as "S", press enter on terminal');
    brush on;
    pause;
    brush off;
    hold off;

    disp('Selected Points:');
    disp(S);
    % Storing Data for Future Usage
    disp("Storing S selected data points...")
    save("./../../data/s.mat","S")
    disp("> Stored")
end

try
    load('C.mat')
    fprintf(1, "\nSkipping Manual selection of C : already found in /data folder...\n")
    disp("> Loaded C points :")
    disp(C)
catch
    % C selection
    imshow(img);
    hold on;
    plot(harrisPoints2);
    axis([C_ROI(1), C_ROI(1)+C_ROI(3), C_ROI(2), C_ROI(2)+C_ROI(4)]);
    title('Select the C circumference points, right click, Export Brushed as "C", press Enter on terminal')
    brush on;
    pause
    brush off;
    hold off;

    disp('Selected Points:');
    disp(C);
    % Storing Data for Future Usage
    save("./../../data/c.mat","C")
end


%% Plotting Results
fprintf(1, "Plotting results\n")
imshow(img);
title("Selected Points:")
hold on;
plot(S(:,1),S(:,2), '+')
plot(C(:,1),C(:,2), '+')
disp("> Done")

%% END
fprintf(1, "------------------------------------------\n>>             Q1_2 : END               <<\n------------------------------------------\n\n")