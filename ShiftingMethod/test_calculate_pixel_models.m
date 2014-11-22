close all
data_load = 0;
if data_load ~= 0
    load_data;
end

% get the models from test data set
[linear_model,linear_lower_limit,linear_upper_limit,...
    non_linear_model,ref_levels,ref_indexes] = calculate_pixel_models(model_pixels,light_level);

figure('Name','Linear model');
plot(linear_model);
figure('Name','Non-linear model');
plot(non_linear_model);