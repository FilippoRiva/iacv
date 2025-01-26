%% Initialization
clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');
load('hl_inf.mat') % hl_inf is the horizontal plane line at infinity
load('lines.mat')
load('c_h.mat') % csi_h is the homogeneous representation of the C circumference

R_img = imref2d(size(img), [0,size(img,2)], [0,size(img,1)]);
ENABLE_PLOTTING = true;

fprintf(1, "------------------------------------------\n>>                 Q2_2                 <<\n------------------------------------------\n\n")

%% Functions

function norm_line = normalize(line)
      norm_line = line ./ line(3);
end

% Using a Stratified Rectification Methodology exploiting the C circuference
%% Affine Rectification 

disp("Calculating affine rectification...")
% Building the H_affine using the line at infinity
H_affine = [eye(2), zeros(2,1);hl_inf(:)'];
assert(norm(inv(H_affine)' * hl_inf' - [0; 0; 1]) < 0.000001, "The H_affine does not what it is supposed to do")

% Applying H_affine 
tform = projtform2d(H_affine);
disp("> H_affine :")
disp(H_affine)
% Show affine rectification results
fprintf(1,"\nShowing affine results...\n")

if ENABLE_PLOTTING 
    outputX = [-200,16000];
    outputY = [-200,10000];
    R_out = imref2d([outputX(2)-outputX(1),outputY(2)-outputY(1)],outputX,outputY);
    [img_aff, R_B] = imwarp(img, R_img ,tform, 'OutputView', R_out);

    figure;

    imshow(img_aff, "XData", R_B.XWorldLimits, "YData", R_B.YWorldLimits)
    axis on
    title("Affine rectification results")
end

disp("> Done")


%% Calculating the metric rectifying homography

fprintf(1,"\nCalculating the metric rectifying homography...\n")
% Calculating the image of the C circumference
Q = inv(H_affine)'*C_h*inv(H_affine);
Q = Q./Q(3,3);

% Computing axes and rotation
Q_2x2 = Q(1:2,1:2);
[V, D_eigen] = eig(Q_2x2);

lambda = diag(D_eigen);

axes = sqrt(abs(1 ./ lambda));
rotation = atan2(V(2, 1), V(1, 1));
U = [cos(rotation), -sin(rotation); sin(rotation), cos(rotation)];

% rescaling the axis to be unitary
S = diag([1, axes(1)/axes(2)]);
K = U*S*U';
A = [K zeros(2,1); zeros(1,2),1];
H_rect = A*H_affine;
disp("> H_rect:")
disp(H_rect)

%% Plotting the result

fprintf(1,"\nPlotting metric rectification results...\n")
if ENABLE_PLOTTING
    tform = projtform2d(H_rect);
    warning('off')
    % Calculating results
    outputX = [-1000,15000];
    outputY = [-2000,11000];
    R_out = imref2d([outputX(2)-outputX(1),outputY(2)-outputY(1)],outputX,outputY);
    [img_rect, R_B] = imwarp(img, R_img ,tform, 'OutputView', R_out);

    % Showing metric rectification
    figure;
    imshow(img_rect, "XData", R_B.XWorldLimits, "YData", R_B.YWorldLimits)
    axis on
    title("Metric rectification results")
end

disp("> Done")

%% Computing Depth for future use
fprintf(1,'\nComputing Depth...\n')
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

dpoints = [ul; ll; lr; ur];

% Calculating points in the rectified image (of the lower face) 
% Notice that here i'm using H_rect and not H_rect_vert
for idx = 1:4
      dpoints(idx,:) = normalize(dpoints(idx,:));
      dpoints(idx,:) = H_rect*dpoints(idx,:)' ;
      dpoints(idx,:) = normalize(dpoints(idx,:));
end

% Calculating depth 
width = norm(dpoints(1,:) - dpoints(4,:));
depth = norm(dpoints(1,:) - dpoints(2,:));
actual_depth = 1/width*depth;
disp('> Depth to width ratio :')
disp(actual_depth)

%% Storing Results
fprintf(1,"\nStoring results...\n")
save('./../../data/h_affine.mat', 'H_affine')
save('./../../data/h_rect.mat', 'H_rect')
save('./../../data/actual_depth.mat', 'actual_depth')
disp("> Done")

%% End
fprintf(1, "------------------------------------------\n>>             Q2_2 : END               <<\n------------------------------------------\n\n")