%% Initialization
clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

% Load the image
img = imread('./../../data/img.jpg');


%% Q1_2
fprintf(1, "------------------------------------------\n>>                 Q1_2                 <<\n------------------------------------------\n\n")

%% Functions
% Plot lines
function plotLines(lines)
    if isstruct(lines)
        plotLinesStruct(lines)
    else 
        plotLinesMat(lines)
    end
end

% Plot a matrix of lines
function plotLinesMat(lines)
    names = ["l1","l2","l3",...
             "h1","h2","h3","h4",...
             "m1","m2","m3","m4","m5","m6"];
    for k = 1:(length(lines)/2)
        xy = [lines(k*2-1,1), lines(k*2-1,2);
                lines(k*2,1), lines(k*2,2)];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        x = (xy(1,1)+xy(2,1))/2;
        y = (xy(1,2)+xy(2,2))/2;
        text(x, y, cellstr(names(k)), 'FontSize', 10, 'Color', 'blue');
    end
end

% Plot the struct of lines
function plotLinesStruct(lines)
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        x = (xy(1,1)+xy(2,1))/2;
        y = (xy(1,2)+xy(2,2))/2;
        if isfield(lines, 'name')
            text(x, y, lines(k).name, 'FontSize', 10, 'Color', 'blue');
        else 
            text(x, y, cellstr(num2str(k)), 'FontSize', 10, 'Color', 'blue');
        end
    end
end


%% Preprocessing

gray = rgb2gray(img);
gray = histeq(gray);

%% Edge Detection
% Extracting edges using Sobel
disp("Extracting Edges...")
method = 'Sobel';
hEdges = edge(gray, method, 0.05, "horizontal");
vEdges = edge(gray, method, 0.05, 'vertical');
disp("> Done")

%% Hough Transform 
% Performing Hough Transform for horizontal lines
fprintf(1, "\nPerforming Hough Transform on horizontal lines\n")
[H,T,R] = hough(hEdges,'RhoResolution',0.5,'Theta',-90:0.5:89);
P = houghpeaks(H,50,'threshold',ceil(0.3*max(H(:))), 'NHoodSize', [97 37]);
hlines = houghlines(hEdges, T, R, P, 'FillGap', 100, 'MinLength', 50);
disp("> Done")

% Performing Hough Transform for vertical lines
fprintf(1, "\nPerforming Hough Transform on vertical lines\n")
[H,T,R] = hough(vEdges,'RhoResolution',0.5,'Theta',-90:0.5:89);
P = houghpeaks(H,50,'threshold',ceil(0.3*max(H(:))), 'NHoodSize', [97 37]);
vlines = houghlines(vEdges, T, R, P, 'FillGap', 100, 'MinLength', 50);
disp("> Done")

%% Detected Lines Plotting
% Plot the lines
fprintf(1, "\nPlotting automatically detected lines\n")
f2 = figure();
imshow(img);
hold on;
title("Automatically detected lines")

lines = [hlines, vlines];
plotLines(lines);
disp("> Done")

%% Choosing Lines

names =["l1","l2","l3",...
       "h1","h2","h3","h4",...
       "m1","m2","m3","m4","m5","m6"];
idxs =[7,2,-1,...
       10,9,11,12,...
       -1,-1,-1,-1,17,-1];

% insertion into variables
l2 = [lines(idxs(2)).point1;
      lines(idxs(2)).point2];
h1 = [lines(idxs(4)).point1;
      lines(idxs(4)).point2];
h2 = [lines(idxs(5)).point1;
      lines(idxs(5)).point2];
h3 = [lines(idxs(6)).point1;
      lines(idxs(6)).point2];
h4 = [lines(idxs(7)).point1;
      lines(idxs(7)).point2];
m5 = [lines(idxs(12)).point1;
      lines(idxs(12)).point2];

% Manually picked points for lines retrieval
% l3, m1, m2, m3, m4, m6
l1 = [421, 778;
      1178, 753];
l3 = [384, 232;
      1318, 370];
m1 = [403, 250;
      462, 452];
m2 = [774, 302;
      722, 464];
m3 = [1073, 347;
      949, 479];
m4 = [1304, 386;
      1161, 483];
m6 = [1440, 694;
      1188, 751];

function line = get_line(mat)
    p1 = [mat(1,1), mat(1,2), 1];
    p2 = [mat(2,1), mat(2,2), 1];
    line = cross(p1,p2);
end

list = {l1,l2,l3,h1,h2,h3,h4,m1,m2,m3,m4,m5,m6};
lines = struct;

for i = 1:length(names)
      lines(i).name = names(i);
      lines(i).point1 = list{i}(1,:);
      lines(i).point2 = list{i}(2,:);
      lines(i).line = get_line(list{i});
end

%% Plotting Chosen Lines
fprintf(1, "\nPlotting manually selected lines\n")
f3 = figure();
imshow(img);
hold on;
title("Lines after selection")
plotLines(lines)
xlim([200,1500])
ylim([200,800])
disp("> Done")

%% Storing Results
% Storing the results for future use
save('./../../data/lines.mat','lines');

%% END
fprintf(1, "------------------------------------------\n>>             Q1_2 : END               <<\n------------------------------------------\n\n")