% Shifts and averages the response curves of all pixels to provide a shape
% that can be used as a standard model of pixel response

function [shape,errors,noise] = get_average_shape(pixels,light_level,noise_data)
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
        noise(:,i) = calculate_temporal_noise(pixels(:,i),noise_data(i,:),light_level);
    end
    
    mean_error = mean(errors,2);    
    legend('Mean model error')
    %figure('Name','Mean errors');
    error_plot = plot(pixels(:,4),mean_error,'c','LineWidth',3);
    error_aim_plot = plot([0,1022],[2,2],'k--','LineWidth',3);
    ylim([0,25]);
    
    % get mean temporal noise
    mean_noise = mean(noise,2);
    
    noise_plot = plot(pixels(:,4),mean_noise,'m','LineWidth',3);
    legend([error_plot,noise_plot,error_aim_plot],'Model error','Mean temporal noise','2% error target');
    
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

function noise = calculate_temporal_noise(true_pixels,stds,light_level)
    noise = zeros(length(true_pixels),1);
    pixel_limits = zeros(length(true_pixels),2);
    light_limits = zeros(length(true_pixels),2);
    % calculate range of pixel values
    for i = 1:length(true_pixels)
        pixel_limits(i,1) = true_pixels(i) - 2*stds(i);
        pixel_limits(i,2) = true_pixels(i) + 2*stds(i);
    end
    % convert range of pixel values into range of light values
    for i = 1:length(true_pixels)
        light_limits(i,1) = interp1(true_pixels,light_level,pixel_limits(i,1));
        light_limits(i,2) = interp1(true_pixels,light_level,pixel_limits(i,2));
    end
    light_ranges = abs(light_limits(:,1)-light_limits(:,2));
    % calculate noise from range of light values
    for i=1:length(true_pixels)
        noise(i) = 100*light_ranges(i)/light_level(i);
    end
    
    return;
        
end