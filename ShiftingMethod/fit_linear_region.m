close all
%clear all

% load('data/HDR_Pixel_Data_MONO1.mat')
% load('data/HDR_Noise_Data_MONO1.mat')
% 
% light_level=light_level(6:end-5);
% pixels=squeeze(pixel_data(1:48,400,6:end-5));

lower_light_limit = 0.8;
upper_light_limit = 4.2;
lower_index_limit = find(light_level == lower_light_limit);
upper_index_limit = find(light_level == upper_light_limit);

linear_region_pixels = pixels(:,lower_index_limit:upper_index_limit);
linear_region_light_level = light_level(lower_index_limit:upper_index_limit);

num_pixels = size(pixels,1);
num_levels = size(pixels,2);

% fit line to each pixel to find gradient
for i = 1:num_pixels
    p(i,:) = polyfit(linear_region_pixels(i,:),linear_region_light_level,1);
end

linear_region_gradient = p(:,1);
linear_region_intercept = p(:,2);
mean_gradient = mean(linear_region_gradient);
max_intercept = max(linear_region_intercept);
mean_intercept = mean(linear_region_intercept);

% create linear model
uni_pixels = 0:1022;
linear_model = polyval([mean_gradient,max_intercept],uni_pixels);
linear_model(linear_model < 0) = 0;

% calculate shift values
for i = 1:num_pixels
    shift = 0;
    for j = lower_index_limit:upper_index_limit
        nearest_index = find(linear_model > light_level(j),1) - 1;
        interp_pixel = interp1([linear_model(nearest_index) linear_model(nearest_index + 1)],...
            [nearest_index nearest_index+1],...
            light_level(j));
        
        shift = shift + interp_pixel - pixels(i,j);
    end
    shifts(i) = round(shift / length(lower_index_limit:upper_index_limit));
end

figure('Name','Linear model');
title('Linear model plotted with actual values');
hold on;
xlabel('Pixel value');
ylabel('Light level cd/m2');
xlim([0 700]);
ylim([0 10]);
for i = 1:num_pixels
    plot(pixels(i,:),light_level,'x');
    plot(uni_pixels - shifts(i),linear_model);
end

figure('Name','Errors in linear model');
title('Percentage errors in linear model');
hold on;
xlabel('Pixel value');
ylabel('Percentage error');
xlim([0 700]);
ylim([0 10]);

% caculate errors
for i = 1:num_pixels
    for j = 1:num_levels
        actual = light_level(j);
        lower_pixel = floor(pixels(i,j));
        predicted = interp1([lower_pixel lower_pixel + 1],...
            [linear_model(lower_pixel), linear_model(lower_pixel + 1)],...
            pixels(i,j));
        errors(i,j) = abs(actual-predicted)/actual * 100;
    end
    plot(pixels(i,:),errors(i,:),'x');
end
plot([0,1022],[4,4],'k--','LineWidth',2);