% calculate_pixel_models

lookup_table = calculate_lookup_table(real_pixels,light_level,...
    linear_model,linear_lower_limit,linear_upper_limit,...
    non_linear_model,ref_levels,ref_indexes);

width = size(real_pixels,2);
height = size(real_pixels,1);

close all
for i = 1:height
    for j = 1:width
        figure;
        uni_pixels = 1:1022;
        hold on;
        xlim([0 1022]);
        l = lookup_table(i,j);
        linear_end = l.crossing - l.l_shift;
        non_linear_end = l.crossing - l.nl_shift;
        plot(squeeze(real_pixels(i,j,:)),light_level,'x');
        plot(uni_pixels(1:linear_end) + l.l_shift,linear_model(1:linear_end));
        plot(uni_pixels(non_linear_end:end) + l.nl_shift,non_linear_model(non_linear_end:end) - l.v_shift);
        if ~isnan(l.crossing)
            plot(l.crossing,2,'x','MarkerSize',10)
        end
    end
end
