close all
%clear all

% load('data/HDR_Pixel_Data_MONO1.mat')
% load('data/HDR_Noise_Data_MONO1.mat')
% 
% light_level=light_level(6:end-5);
% pixels=squeeze(pixel_data(1:48,400,6:end-5))';
% noise_data=squeeze(all_std_images(1:48,500,6:end-5));

% condition data by removing non-monotonically increasing data
for i = 1:size(pixels,2)
    while find(diff(pixels(:,i)) <= 0, 1)
        change = find(diff(pixels(:,i)) <= 0, 1) + 1;
        pixels(change,i) = pixels(change-1,i) + 0.001;
    end
end

[shape,errors,noise] = get_average_shape(pixels,light_level,noise_data);