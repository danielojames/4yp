close all

pixels = pixel_data(51:60,51:60,6:end-5);
num_actual_levels = size(pixels,3);

lookup_table = calculate_lookup_table(pixels,light_level,...
    linear_model,linear_lower_limit,linear_upper_limit,...
    non_linear_model,ref_levels,ref_indexes);

test_pixels = 1:1022;
height = size(pixels,1);
width = size(pixels,2);
num_levels = length(test_pixels);
l_map = zeros(height,width,num_levels);

for i = 1:num_levels
    test_image = ones(height,width) * test_pixels(i);
    l_map(:,:,i) = get_luminance_map(test_image,linear_model,non_linear_model,lookup_table);
end

for i = 1:height
    for j = 1:width
        for k = 1:num_levels
            test_pixel(k) = l_map(i,j,k);
        end
        shapes(i,j,:) = test_pixel;
        
        for k = 1:num_actual_levels
            actual = light_level(k);
            lower_pixel = floor(pixels(i,j,k));
            if lower_pixel < 1022
                upper_pixel = lower_pixel + 1;
                predicted = interp1([lower_pixel upper_pixel],...
                    [shapes(i,j,lower_pixel) shapes(i,j,upper_pixel)],...
                    pixels(i,j,k));
            else
                predicted = shapes(i,j,lower_pixel);
            end
            pixel_errors(k) = 100*((actual-predicted)/actual);
        end
        errors(i,j,:) = abs(pixel_errors);
        
        figure;
        xlim([0 1022]);
        hold on;
        plot(test_pixels,squeeze(shapes(i,j,:)));
        plot(squeeze(pixels(i,j,:)),light_level,'x');
        plot(squeeze(pixels(i,j,:)),squeeze(errors(i,j,:)),'x');
    end
end

figure;
xlim([0 1022]);
ylim([0 20]);
hold on;
for i = 1:height
    for j = 1:width
        plot(squeeze(pixels(i,j,:)),squeeze(errors(i,j,:)),'x')
    end
end

plot([0 1022],[4 4],'k-.','LineWidth',4);