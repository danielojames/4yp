% Shifts and averages the response curves of all pixels to provide a shape
% that can be used as a standard model of pixel response

function shape = get_average_shape(pixels,light_level,noise_data)
    % the light levels to calculate the shift at
    ref_levels = [2.5,4.2,8,9.5,21,40,55,90,100];
    num_pixels = size(pixels,2);
    
    % convert light levels into indexes so the pixel values can be found
    for i = 1:length(ref_levels)
        ref_indexes(i) = find(light_level == ref_levels(i),1);
    end
    
    % choose and plot reference pixel
    ref_pixel = pixels(:,1);    
    shifts(1) = 0;    
    figure('Name','Shifted-pixels');
    hold on;    
    
    % plot reference pixel
    plot(ref_pixel,light_level)
    
    for i=2:num_pixels
        shift = 0;
        for j=1:length(ref_indexes)
            % find difference for each light level
            shift = shift + pixels(ref_indexes(j),i) - ref_pixel(ref_indexes(j));
        end
        
        % take mean of shifts as the shift value 
        shifts(i) = shift / length(ref_indexes);
        
        % plot shifted data for each pixel
        plot(pixels(:,i) - shifts(i),light_level)
    end
    
    % do linear interpolation to find evenly spaced data set
    uni_pixels = ceil(min(pixels(:,1))):1020;
    for i=1:num_pixels
        light_levels_interp(:,i) = interp1(pixels(:,i) - shifts(i),...
            light_level,uni_pixels);
    end
    
    shape = mean(light_levels_interp,2);
    
    % plot shape
    plot(uni_pixels,shape,'c','LineWidth',3)
    
    figure('Name','Shifted-shape');
    hold on;
    % plot shape against pixels at original, un-shifted, values
    for i = 1:num_pixels
        plot(pixels(:,i),light_level,'x','MarkerSize',1);
        plot(uni_pixels+shifts(i),shape,'c');
    end
    
    % calculate errors
    figure('Name','Absolute errors');
    hold on;
    for i = 1:num_pixels
        errors(:,i) = calculate_errors(uni_pixels+shifts(i),shape,pixels(:,i),light_level);
    end
    
    errors = mean(errors,2);
    %figure('Name','Mean errors');
    plot(pixels(:,4),errors,'c','LineWidth',3);
    plot([0,1022],[2,2],'k--','LineWidth',3)
    ylim([0,25]);
    
    % calculate mean temporal noise
    % convert pixel values to loight levels using lookup table
    % 2 standard deviations above and below
    % then calcualte error
    mean_pixels = mean(pixels,2)';
    noise = abs((noise_data * 2)./mean_pixels)*100;
    plot(pixels(:,4),noise,'m','LineWidth',3);
    
    return
end

function errors = calculate_errors(model_pixels,model,true_pixels,true_light_level)
    for i = 1:length(true_pixels)
        predicted_level = interp1(model_pixels,model,true_pixels(i));
        errors(i) = abs(predicted_level-true_light_level(i))/true_light_level(i)*100;
    end
    plot(true_pixels,errors,'x','MarkerSize',4);
    return
end