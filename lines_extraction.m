clc
clear
close all

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

function plot_lines(lines)
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        disp(xy)
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    
        % Plot beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
end


[H,T,R] = hough(vEdges,'RhoResolution',0.5,'Theta',-90:0.5:89);
P = houghpeaks(H,50,'threshold',ceil(0.3*max(H(:))), 'NHoodSize', [97 37]);
vlines = houghlines(vEdges, T, R, P, 'FillGap', 100, 'MinLength', 50);

disp(vlines);

% Plot the lines
f2 = figure();
brush on;
imshow(img);
hold on;

plot_lines(hlines)
plot_lines(vlines)

% Lines selection through brush instrument, assuming that 
% the naming is coherent with the homework assignment
title("Use brush instrument to select the useful lines")
pause
close all

% Manual lines retrieval
% l1, m1, m2, m3, m4, m6
f3 = figure();
imshow(img)
title('Get l1')
[x, y] = getpts();
l1 = [x(1:2)'; y(1:2)'];

mi = zeros(6, 2, 2);
mi(5, :, :) = m5;
for k = 1:6
    if k ~= 5
        title('Get m'+string(k));
        [x, y] = getpts();
        mi(k, :, :) = reshape([x(1:2)'; y(1:2)'], [2, 2]);
        disp(squeeze(mi(k,:,:)))
    end
end

function line = get_line(mat)
    p1 = [mat(1,1), mat(2,1), 1];
    p2 = [mat(1,2), mat(2,2), 1];
    line = cross(p1,p2);
end

% storing the result as homogeneous coordinates
res = [
        get_line(l1); 
        get_line(l2);
        get_line(l3);
        get_line(squeeze(mi(1, :, :)));
        get_line(squeeze(mi(2, :, :)));
        get_line(squeeze(mi(3, :, :)));
        get_line(squeeze(mi(4, :, :)));
        get_line(squeeze(mi(5, :, :))); ...
        get_line(squeeze(mi(6, :, :)));
        get_line(h1);
        get_line(h2);
        get_line(h3);
        get_line(h4)
];
disp(res);

% Storing the results for future use
save('lines.mat','res');

close all 