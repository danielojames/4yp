close all
%clear all

% load('data/HDR_Pixel_Data_MONO1.mat')
% load('data/HDR_Noise_Data_MONO1.mat')
% 
% light_level=light_level(6:end-5);
% pixels=squeeze(pixel_data(1:48,400,6:end-5));

% plot pixels to be examined

figure('Name','Pixels to examine shift charactersitics of');

hold on;
for i = 5:15
    plot(pixels(i,:),light_level)
end

ref_pixel = pixels(5,:);
test_pixels = pixels(6:15,:);
num_pixels = size(test_pixels,1);
ref_pixel_plot = plot(ref_pixel,light_level,'g-.','LineWidth',2);
legend([ref_pixel_plot],'Reference pixel','Location','North')
title('Pixels to examine shift charactersitics of');
xlabel('Pixel value');
ylabel('Light intensity cd/m2');

% the light levels to calculate shift at
levels_to_examine = [1.5 2.5 4.003 13 19 28 55 70 90];
num_levels = length(levels_to_examine);
% find corresponding indexes for light levels
for i = 1:num_levels
    indexes_to_examine(i) = find(light_level == levels_to_examine(i),1);
end
% calculate shifts
shifts = zeros(num_pixels,num_levels);
mean_shifts = zeros(num_pixels,3);
norm_mean_shifts = mean_shifts;
for i = 1:num_pixels
    for j = 1:num_levels
        shifts(i,j) = test_pixels(i,j) - ref_pixel(j);
    end
end

shifts_r1 = shifts(:,1:3);
shifts_r2 = shifts(:,4:6);
shifts_r3 = shifts(:,7:9);
mean_shifts(:,1) = mean(shifts_r1,2);
mean_shifts(:,2) = mean(shifts_r2,2);
mean_shifts(:,3) = mean(shifts_r3,2);

figure('Name','Shifts in each region');
title('Shift in each pixel region');
hold on;
set(gca, 'XTick',[1,2,3])
set(gca, 'XTickLabel',{'1st','2nd','3rd'})
xlabel('Region');
ylabel('Shift');
for i = 1:num_pixels
    plot(1:3,mean_shifts(i,:),'x-');
end

figure('Name','Mean shifts in each region');
title('Mean shift in each pixel region');
hold on;
set(gca, 'XTick',[1,2,3])
set(gca, 'XTickLabel',{'1st','2nd','3rd'})
xlabel('Region');
ylabel('Mean shift');
ylim([0 3]);
for i = 1:num_pixels
    norm_mean_shifts(i,:) = abs(mean_shifts(i,:)./mean_shifts(i,1));
    plot(1:3,norm_mean_shifts(i,:),'x-');
end




