clc
clear
close all

function plotLines(lines)
    if isstruct(lines)
        plotLinesStruct(lines)
    else 
        plotLinesMat(lines)
    end
end

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


% Loading the image
img = imread('img.jpg');

% Preprocessing
gray = rgb2gray(img);
gray = histeq(gray);

% Extracting edges using Sobel
method = 'Sobel';
hEdges = edge(gray, method, 0.05, "horizontal");
vEdges = edge(gray, method, 0.05, 'vertical');

% Performing Hough Transform for horizontal lines
[H,T,R] = hough(hEdges,'RhoResolution',0.5,'Theta',-90:0.5:89);
P = houghpeaks(H,50,'threshold',ceil(0.3*max(H(:))), 'NHoodSize', [97 37]);
hlines = houghlines(hEdges, T, R, P, 'FillGap', 100, 'MinLength', 50);

% Performing Hough Transform for vertical lines
[H,T,R] = hough(vEdges,'RhoResolution',0.5,'Theta',-90:0.5:89);
P = houghpeaks(H,50,'threshold',ceil(0.3*max(H(:))), 'NHoodSize', [97 37]);
vlines = houghlines(vEdges, T, R, P, 'FillGap', 100, 'MinLength', 50);

% Plot the lines
f2 = figure();
imshow(img);
hold on;
title("Automatically detected lines")

lines = [hlines, vlines];
plotLines(lines);

% manually chosen
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

disp("Click to move on")
waitforbuttonpress
close(f2)

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

f3 = figure();
imshow(img);
hold on;
title("Lines after selection and manual intervention")
plotLines(lines)

% Storing the results for future use
save('lines.mat','lines');