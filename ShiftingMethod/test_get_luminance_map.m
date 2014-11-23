close all

pixels = pixel_data(51:60,51:60,6:end-5);

lookup_table = calculate_lookup_table(pixels,light_level,...
    linear_model,linear_lower_limit,linear_upper_limit,...
    non_linear_model,ref_levels,ref_indexes);

for i=1:length(light_level)
    im = squeeze(pixels(:,:,i));
    l_map = get_luminance_map(im,linear_model,non_linear_model,lookup_table);
    figure('Name',['Light level: ',num2str(light_level(i))]);
    colormap('hsv');
    image(l_map);
    max_l = max(max(l_map));
    min_l = min(min(l_map));
    mean_l = mean(mean(l_map));
    mean_error = abs(100*(light_level(i) - mean_l)/light_level(i));
    mean_pixel = mean(mean(im));
    annotation_string = ['Max value: ',num2str(max_l),char(10),...
        'Min value: ',num2str(min_l),char(10),...
        'Mean value: ',num2str(mean_l),char(10),...
        'Mean error: ',num2str(mean_error)];
    annotation('textbox',[0.2,0.5,0.18,0.11],'String',annotation_string)
end