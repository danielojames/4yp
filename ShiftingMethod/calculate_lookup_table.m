function lookup_table = calculate_lookup_table(pixels,light_level,...
    linear_model,linear_lower_limit,linear_upper_limit,...
    non_linear_model,ref_levels,ref_indexes)
    width = size(pixels,2);
    height = size(pixels,1);
    linear_shift = get_linear_shift(pixels,light_level,linear_model,linear_lower_limit,linear_upper_limit);
    non_linear_shift = get_non_linear_shift(pixels,non_linear_model,ref_levels,ref_indexes);
    [vertical_shift, crossover_points] = get_vertical_shift_and_crossover(...
        linear_model,non_linear_model,linear_shift,non_linear_shift,pixels);
    
    % make lookup table of structs
    for i = 1:height
        for j = 1:width
            lookup_table(i,j) = struct('l_shift',linear_shift(i,j),...
                'nl_shift',non_linear_shift(i,j),...
                'v_shift',vertical_shift(i,j),...
                'crossing',crossover_points(i,j));
        end
    end
    return;
end

function linear_shift = get_linear_shift(pixels,light_level,linear_model,...
    lower_index_limit,upper_index_limit)
    width = size(pixels,2);
    height = size(pixels,1);
    for i = 1:height
        for j = 1:width
            shift = 0;
            for k = lower_index_limit:upper_index_limit
                nearest_index = find(linear_model > light_level(k),1) - 1;
                interp_pixel = interp1([linear_model(nearest_index) linear_model(nearest_index + 1)],...
                    [nearest_index nearest_index+1],...
                    light_level(k));
                shift = shift + interp_pixel - pixels(i,j,k);
            end
            linear_shift(i,j) = round(shift / length(lower_index_limit:upper_index_limit));
        end
    end
end

function non_linear_shift = get_non_linear_shift(pixels,...
    non_linear_model,ref_levels,ref_indexes)
    width = size(pixels,2);
    height = size(pixels,1);
    uni_pixels = 1:1022;
    
    for i = 1:height
        for j = 1:width
            shift = 0;
            for k=1:length(ref_indexes)
                % find difference for each light level
                actual_pixel = pixels(i,j,ref_indexes(k));
                model_pixel = find(non_linear_model >= ref_levels(k),1) + min(uni_pixels);
                shift = shift + actual_pixel - model_pixel;
            end
            % take mean of shifts as the shift value 
            non_linear_shift(i,j) = round(shift / length(ref_indexes));
        end
    end
end

function [vertical_shift, crossover] = get_vertical_shift_and_crossover(...
    linear_model,non_linear_model,linear_shift,non_linear_shift,pixels)
    width = size(pixels,2);
    height = size(pixels,1);
    uni_pixels = 1:1022;
    
    % first need lowest index of a non-NaN non-linear model value
    [non_linear_start_value,non_linear_start_index] = min(non_linear_model);
    % create vector to store crossover points
    crossover = nan(height,width);
    vertical_shift = zeros(height,width);
    
    for i = 1:height
        for j = 1:width
            % shift pixels
            linear_eff_pixels(i,j,:) = uni_pixels + linear_shift(i,j);
            non_linear_eff_pixels(i,j,:) = uni_pixels + non_linear_shift(i,j);
            % shifted pixel value where non-linear model starts
            non_linear_eff_start_pixels(i,j) = non_linear_start_index + non_linear_shift(i,j);
            % corresponding index of linear model where non-linear model starts
            linear_eff_start_indexes(i,j) = non_linear_eff_start_pixels(i,j) - linear_shift(i,j);
            % start at the start of non-linear model and loop through looking for a
            % cross over point between linear and non-linear model. If there is no
            % crossing point the crossover value is left as NaN
            for k = 1:800-non_linear_eff_start_pixels(i,j)
                if non_linear_model(non_linear_start_index + k) < linear_model(linear_eff_start_indexes(i,j) + k)
                    % the crossover value is stored as the pixel value received
                    % from the camera
                    crossover(i,j) = non_linear_eff_start_pixels(i,j) + k;
                end
            end

            % for pixels that have no crossover point, try brute force approach
            % getting the first pixel of the non-linear model to line up vertically 
            % with that of the linear model
            if isnan(crossover(i,j))
                vertical_shift(i,j) = non_linear_model(non_linear_start_index) - linear_model(linear_eff_start_indexes(i,j));    
                for k = 1:800-non_linear_eff_start_pixels(i,j)
                    if non_linear_model(non_linear_start_index + k) - vertical_shift(i,j) < linear_model(linear_eff_start_indexes(i,j) + k)
                        % the crossover value is stored as the pixel value received
                        % from the camera
                        crossover(i,j) = non_linear_eff_start_pixels(i,j) + k;
                    end
                end
            end        
        end
    end

end
    