function lookup_table = get_lookup_table(pixels,light_levels,shape)
    height = size(pixels,1);
    width = size(pixels,2);
    
    num_pixels = min(size(pixels));
    
    lookup_table = zeros(num_pixels,1);
    
    % choose reference light levels
    ref_levels = [2.5,4.2,8,9.5,21,40,55,90,100];
    num_refs = length(ref_levels);
    for i = 1:num_refs
        tmp = abs(shape - ref_levels(i));
        [tmp,shape_index(i)] = min(tmp);
        ref_index(i) = find(light_levels == ref_levels(i),1);
    end
    
    % for every pixel
    for i = 1:num_pixels
        shift = 0;
        for k = 1:num_refs
            shift = shift + (pixels(i,ref_index(k)) - shape_index(k));
        end
        shift = floor(shift/num_refs);
        lookup_table(i)=shift;
    end
    % find pixel value for each pixel at the reference light levels
    % find difference between measured pixel value and model pixel value
    % calculate mean difference
    % this is the shift
end

