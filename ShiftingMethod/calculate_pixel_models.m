function [linear_model,linear_lower_limit,linear_upper_limit,...
    non_linear_model,ref_levels,ref_indexes] = calculate_pixel_models(pixels,light_level)

    [linear_model,linear_lower_limit,linear_upper_limit] = calculate_linear_model(pixels,light_level);
    
    [non_linear_model,ref_levels,ref_indexes] = calculate_non_linear_model(pixels,light_level);
end

% this function creates a linear model that is the mean representation of
% the pixels supplied to the function. The pixels should be supplied as a
% matrix with each pixel on a new row and each column representing a light
% level
function [linear_model,lower_index_limit,upper_index_limit] = calculate_linear_model(pixels,light_level)
    % light levels between which the linear region should be modelled
    lower_light_limit = 0.8;
    upper_light_limit = 4.2;
    lower_index_limit = find(light_level == lower_light_limit,1);
    upper_index_limit = find(light_level == upper_light_limit,1);
    
    % trim the data so only the desired region is left
    pixels = pixels(:,lower_index_limit:upper_index_limit);
    light_level = light_level(lower_index_limit:upper_index_limit);
    
    num_pixels = size(pixels,1);
    num_levels = length(light_level);
    
    % fit a straight line to each pixel to find the gradient and intercepts
    for i = 1:num_pixels
        p(i,:) = polyfit(pixels(i,:),light_level,1);
    end
    
    gradients = p(:,1);
    intercepts = p(:,2);    
    mean_gradient = mean(gradients);
    max_intercept = max(intercepts);
    
    % create linear model for all pixels - setting any values below 0 to 0
    uni_pixels = 1:1022;
    linear_model = polyval([mean_gradient,max_intercept],uni_pixels);
    linear_model(linear_model < 0) = 0;
    return;
end

% this function creates a non-linear model that is the mean representation
% ofthe pixels supplied to the function. The pixels should be supplied as a
% a matrix with each pixel on a new row and each column representing a
% light level
function [non_linear_model,ref_levels,ref_indexes] = calculate_non_linear_model(pixels,light_level)
    num_pixels = size(pixels,1);
    num_levels = length(light_level);
    % the light level where we consider the non_linear region to
    % approximately start
    light_limit = 4.2;
    light_limit_index = find(light_level == light_limit,1);
    
    % make sure data is monotonically increasing
    for i = 1:size(pixels,1)
        while find(diff(pixels(i,:)) <= 0, 1)
            change = find(diff(pixels(i,:)) <= 0, 1) + 1;
            pixels(i,change) = pixels(i,change-1) + 0.001;
        end
    end
    
    % the light levels at which the shifts should be calculated
    ref_levels = [8,9.5,21,40,46,55,90];
    
    % convert light levels into indexes so the pixel values can be found
    for i = 1:length(ref_levels)
        ref_indexes(i) = find(light_level == ref_levels(i),1);
    end
    
    % choose a reference pixel - in the middle of the sample bunch
    temp = sort(pixels(:,68));
    ref_value = temp(ceil(length(temp)/2));
    ref_index = find(pixels(:,68) == ref_value,1);
    ref_pixel = pixels(ref_index,:);
    
    % shift the pixels on to the reference pixel
    for i = 1:num_pixels
        shift = 0;
        for j=1:length(ref_indexes)
            % find difference for each light level
            shift = shift + pixels(i,ref_indexes(j)) - ref_pixel(ref_indexes(j));
        end
        % take mean of shifts as the shift value 
        shifts(i) = shift / length(ref_indexes);
    end
    
    % do linear interpolation to find evenly spaced data set
    uni_pixels = 1:1022;
    for i=1:num_pixels
        light_levels_interp(i,:) = interp1(pixels(i,:) - shifts(i),...
            light_level,uni_pixels);
    end
    
    non_linear_model = nanmean(light_levels_interp,1);
    non_linear_model(1:400) = nan(1,400);
end