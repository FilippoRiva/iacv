function plot_conic(C_h,img,name)
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
    C_2x2 = C_h(1:2,1:2);
    b = C_h(1:2,3);
    center = -C_2x2 \ b;

    % Display the result
    figure;
    imshow(img_rgb);
    text(center(1),center(2),name)
end