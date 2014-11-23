function luminance_map = get_luminance_map(raw_pixels,linear_model,non_linear_model,lookup_table)
    height = size(raw_pixels,1);
    width = size(raw_pixels,2);
    
    luminance_map = zeros(height,width);
    
    for i = 1:height
        for j = 1:width
            p = round(raw_pixels(i,j));
            l = lookup_table(i,j);
            if p > l.crossing
                if p - l.nl_shift > 1022
                    luminance_map(i,j) = non_linear_model(1022);
                else
                    luminance_map(i,j) = non_linear_model(p - l.nl_shift) - l.v_shift;
                end
            else
                if p - l.l_shift > 0
                    luminance_map(i,j) = linear_model(p - l.l_shift);
                else
                    luminance_map(i,j) = 0;
                end
            end
        end
    end
    
    return;
end