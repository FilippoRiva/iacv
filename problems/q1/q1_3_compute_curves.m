clc
clear
close all

addpath(genpath('./../../data'))
addpath(genpath('./../../utils'))

img = imread('img.jpg');

load('c.mat')
load('s.mat')

function C = getConic(x, y)
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

function center = computeConicCenter(C_h)
    C_2x2 = C_h(1:2,1:2);
    b = C_h(1:2,3);
    center = -C_2x2 \ b;
end

function plotConic(C_h,img,name)
    % Compute points that belong to the conic
    im_err = zeros(size(img,1),size(img,2));
    for i = 1:size(img,1)
        for j = 1:size(img,2)
            im_err(i,j) = [j,i,1]*C_h*[j;i;1];
        end
    end
    
    % thresholding the conic
    epsilon = 2e-4;
    conic_mask = abs(im_err)<epsilon;
    
    % Overlay red on conic points
    img_rgb(:, :, 1) = img(:, :, 1) + uint8(255 * conic_mask); % Red channel
    img_rgb(:, :, 2) = img(:, :, 2) .* uint8(~conic_mask);     % Remove green
    img_rgb(:, :, 3) = img(:, :, 3) .* uint8(~conic_mask);     % Remove blue

    % Compute conic center    
    center = computeConicCenter(C_h);

    % Display the result
    figure;
    imshow(img_rgb);
    text(center(1),center(2),name)
end

C_h = getConic(C(:,1),C(:,2));
plotConic(C_h,img,'C')
S_h = getConic(S(:,1),S(:,2));
plotConic(S_h,img,'S')

save('./../../data/c_h.mat','C_h')
save('./../../data/s_h.mat','S_h')
