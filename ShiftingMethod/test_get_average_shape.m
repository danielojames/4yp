close all
%clear all

load('data/HDR_Pixel_Data_MONO1.mat')

light_level=light_level(6:end-5);
pixels=squeeze(pixel_data(1:48,400,6:end-5))';

for i = 1:size(pixels,2)
    while find(diff(pixels(:,i)) <= 0, 1)
        change = find(diff(pixels(:,i)) <= 0, 1) + 1;
        pixels(change,i) = pixels(change-1,i) + 0.001;
    end
end

% condition data by finding diff for each column
% find indices of zero values
% +eps to locations in pixel array at these indices


shape = get_average_shape(pixels,light_level)