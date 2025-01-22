clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');

load('c.mat')
load('s.mat')

function C = get_conic(x, y)
    % this is equivalent to requiring that the conic passes trhough all the six
    % points
    A = [x.^2 x.*y y.^2 x y ones(size(x))];
    [~, ~, V] = svd(A);
    N = V(:, end);
    % change the name of variables
    [a, b, c, d, e, f] = deal(N(1),N(2),N(3),N(4),N(5),N(6));
    % here is the matrix of the conic: off-diagonal elements must be divided
    % by two
    C = [a b/2 d/2; b/2 c e/2; d/2 e/2 f];
    C= C./C(3,3);
end

C_h = get_conic(C(:,1),C(:,2));
plot_conic(C_h,img,'C')
S_h = get_conic(S(:,1),S(:,2));
plot_conic(S_h,img,'S')

save('./../../data/c_h.mat','C_h')
save('./../../data/s_h.mat','S_h')
