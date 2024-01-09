function descriptors = GLOH_descriptors...
    (gradient,...
    angle,...
    key_point_array,...
    Path_Block,...
    ratio,...
    sigma_1)

    LOG_POLAR_WIDTH = 16;
    LOG_POLAR__HIST_BINS = 12;
    circle_count = 2;
    
    M = size(key_point_array, 1);
    d = LOG_POLAR_WIDTH;
    n = LOG_POLAR__HIST_BINS;
    descriptors = zeros(M, (circle_count * d + 1) * n);
    locs = key_point_array;

  
    
   
    parfor i = 1:1:M
        x = key_point_array(i, 1);
        y = key_point_array(i, 2);
        layer = key_point_array(i, 3);
        main_angle = key_point_array(i, 4);
        current_gradient = gradient{layer};
        current_angle = angle{layer};
        descriptors(i, :) = calc_log_polar_descriptor(current_gradient, current_angle, x, y, main_angle, d, n, Path_Block, circle_count);
    end
    
    descriptors = struct('locs', locs(:,:), 'des', descriptors(:, :));
 
