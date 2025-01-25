%% Initialization
clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');

load('c.mat')
load('s.mat')

%% Q1_3
fprintf(1, "------------------------------------------\n>>                 Q1_3                 <<\n------------------------------------------\n\n")

%% Functions
function C = get_conic(x, y)
    % Building the system
    A = [x.^2 x.*y y.^2 x y ones(size(x))];
    [~, ~, V] = svd(A);
    N = V(:, end);
    % Get coefficients
    [a, b, c, d, e, f] = deal(N(1),N(2),N(3),N(4),N(5),N(6));
    % Get the matrix from coefficients
    C = [a b/2 d/2; b/2 c e/2; d/2 e/2 f];
    C= C./C(3,3);
end

%% Computing C
disp("Computing and plotting C...")
C_h = get_conic(C(:,1),C(:,2));
plot_conic(C_h,img,'C')
disp("> Done")

%% Computing S
fprintf(1,"\nComputing and plotting S...\n")
S_h = get_conic(S(:,1),S(:,2));
plot_conic(S_h,img,'S')
disp("> Done")

%% Saving
fprintf(1,"\nStoring results...\n")
save('./../../data/c_h.mat','C_h')
save('./../../data/s_h.mat','S_h')
disp("> Done")

%% End
fprintf(1, "------------------------------------------\n>>             Q1_3 : END               <<\n------------------------------------------\n\n")