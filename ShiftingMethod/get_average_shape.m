% Shifts and averages the response curves of all pixels to provide a shape
% that can be used as a standard model of pixel response

function shape = get_average_shape(pixels,light_level)
    ref_levels = [4.2,8,9.5,21,40,55,90,100];
    for i = 1:length(ref_levels)
        ref_indexes(i) = find(light_level == ref_levels(i),1);
    end
    
    % choose and plot reference pixel
    ref_pixel = pixels(:,1);    
    shifts(1) = 0;    
    figure;
    hold on;    
    plot(ref_pixel,light_level)
    
    for i=2:size(pixels,2)
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
    
    shape = shifts;
    return
end