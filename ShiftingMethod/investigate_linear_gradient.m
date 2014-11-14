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

% plot pixels to be examined
linear_region_pixels = pixels(:,lower_index_limit:upper_index_limit);
linear_region_light_level = light_level(lower_index_limit:upper_index_limit);

num_pixels = size(linear_region_pixels,1);

figure('Name','Linear region');
xlabel('Pixel value');
ylabel('Light level cd/m2');
plot(linear_region_pixels,linear_region_light_level,'x-');

for i = 1:num_pixels
    p(i,:) = polyfit(linear_region_pixels(i,:),linear_region_light_level,1);
end

linear_region_gradient = p(:,1);
mean_gradient = mean(linear_region_gradient);
std_gradient = std(linear_region_gradient);
max_error = std_gradient/mean_gradient * 100;

figure('Name','Gradient in linear region');
xlabel('Pixel number');
ylabel('Gradient');
hold on;

plot(linear_region_gradient,'x');
mean_gradient_plot = plot([1 num_pixels],[mean_gradient mean_gradient],'--','LineWidth',3);
std_gradient_plot = plot([1 num_pixels],[mean_gradient+2*std_gradient mean_gradient+2*std_gradient],'b--','LineWidth',2);
plot([1 num_pixels],[mean_gradient-2*std_gradient mean_gradient-2*std_gradient],'b--','LineWidth',2);

mean_gradient_string = strcat('Mean gradient: ',num2str(mean_gradient));
std_gradient_string = strcat('2 standard deviations: ',strcat(num2str(std_gradient),'%'));

legend([mean_gradient_plot std_gradient_plot],mean_gradient_string,std_gradient_string);