fit_linear_region;

for i = 1:size(pixels,1)
    while find(diff(pixels(i,:)) <= 0, 1)
        change = find(diff(pixels(i,:)) <= 0, 1) + 1;
        pixels(i,change) = pixels(i,change-1) + 0.001;
    end
end

light_limit = 4.2;
light_limit_index = find(light_level == light_limit,1);
non_linear_light_level = light_level(light_limit_index:end);
non_linear_pixels = pixels(:,light_limit_index:end);

ref_levels = [8,9.5,21,40,55,90,100];
num_pixels = size(non_linear_pixels,1);
num_levels = length(light_level);

% convert light levels into indexes so the pixel values can be found
for i = 1:length(ref_levels)
    ref_indexes(i) = find(non_linear_light_level == ref_levels(i),1);
end

% choose and plot reference pixel
temp = sort(pixels(:,68));
ref_value = temp(ceil(length(temp)/2));
ref_index = find(pixels(:,68) == ref_value,1);
ref_pixel = non_linear_pixels(ref_index,:);
non_linear_shifts(1) = 0;    
figure('Name','Shifted-pixels');
hold on;    

% plot reference pixel
plot(ref_pixel,non_linear_light_level)

for i=1:num_pixels
    if i ~= ref_index
        shift = 0;
        for j=1:length(ref_indexes)
            % find difference for each light level
            shift = shift + non_linear_pixels(i,ref_indexes(j)) - ref_pixel(ref_indexes(j));
        end

        % take mean of shifts as the shift value 
        non_linear_shifts(i) = shift / length(ref_indexes);

        % plot shifted data for each pixel
        plot(non_linear_pixels(i,:) - non_linear_shifts(i),non_linear_light_level)
    else
        non_linear_shifts(i) = 0;
    end
end

% do linear interpolation to find evenly spaced data set
uni_pixels = 1:1022;
for i=1:num_pixels
    light_levels_interp(i,:) = interp1(non_linear_pixels(i,:) - non_linear_shifts(i),...
        non_linear_light_level,uni_pixels);
end

non_linear_model = nanmean(light_levels_interp,1);

% get new shifts by fitting shape to data
for i=1:num_pixels
    shift = 0;
    for j=1:length(ref_indexes)
        % find difference for each light level
        actual_pixel = non_linear_pixels(i,ref_indexes(j));
        model_pixel = find(non_linear_model >= ref_levels(j),1) + min(uni_pixels);
        shift = shift + actual_pixel - model_pixel;
    end

    % take mean of shifts as the shift value 
    non_linear_shifts(i) = round(shift / length(ref_indexes));
end

plot(uni_pixels,non_linear_model,'c','LineWidth',3)

% find model crossover points
% first need lowest index of a non-NaN non-linear model value
[non_linear_start_value,non_linear_start_index] = min(non_linear_model);
% create vector to store crossover points
model_crossovers = nan(num_pixels,1);
vertical_shifts = zeros(num_pixels,1);
for i = 1:num_pixels
    % shift pixels
    linear_eff_pixels(i,:) = uni_pixels + linear_shifts(i);
    non_linear_eff_pixels(i,:) = uni_pixels + non_linear_shifts(i);
    % shifted pixel value where non-linear model starts
    non_linear_eff_start_pixels(i) = non_linear_start_index + non_linear_shifts(i);
    % corresponding index of linear model where non-linear model starts
    linear_eff_start_indexes(i) = non_linear_eff_start_pixels(i) - linear_shifts(i);
    % start at the start of non-linear model and loop through looking for a
    % cross over point between linear and non-linear model. If there is no
    % crossing point the crossover value is left as NaN
    for j = 1:800-non_linear_eff_start_pixels(i)
        if non_linear_model(non_linear_start_index + j) < linear_model(linear_eff_start_indexes(i) + j)
            % the crossover value is stored as the pixel value received
            % from the camera
            model_crossovers(i) = non_linear_eff_start_pixels(i) + j;
        end
    end
    
    % for pixels that have no crossover point, try brute force approach
    % getting the first pixel of the non-linear model to line up vertically 
    % with that of the linear model
    if isnan(model_crossovers(i))
        vertical_shifts(i) = non_linear_model(non_linear_start_index) - linear_model(linear_eff_start_indexes(i));    
        for j = 1:800-non_linear_eff_start_pixels(i)
            if non_linear_model(non_linear_start_index + j) - vertical_shifts(i) < linear_model(linear_eff_start_indexes(i) + j)
                % the crossover value is stored as the pixel value received
                % from the camera
                model_crossovers(i) = non_linear_eff_start_pixels(i) + j;
            end
        end
    end        
end

% calculate errors
non_linear_errors = [];
figure('Name','Non-linear model percentage errors');
hold on;
title('Percentage errors of the non-linear model');
xlabel('Pixel value');
ylabel('Percentage error');
xlim([0,1022]);
errors = zeros(num_pixels,num_levels);
for i = 1:num_pixels
    % create a shape for each pixel over all pixel value, combining the
    % linear and non-linear models
    linear_end = model_crossovers(i) - linear_shifts(i);
    non_linear_end = model_crossovers(i) - non_linear_shifts(i);
    if linear_shifts(i) >= 0
        zero_padding = zeros(1,abs(linear_shifts(i)));
        shape = [zero_padding linear_model(1:linear_end) non_linear_model(non_linear_end:end)-vertical_shifts(i)];
    else
        shape = [linear_model(-linear_shifts(i):linear_end-1) non_linear_model(non_linear_end:end)-vertical_shifts(i)];
    end
    if length(shape) < 1023
        shape(end:1023) = 110;
    end
    shapes(i,:) = shape(2:1023);
    for j = 1:num_levels
        actual = light_level(j);
        lower_pixel = floor(pixels(i,j));
        if lower_pixel < 1022
            predicted = interp1([lower_pixel lower_pixel + 1],...
                [shapes(i,lower_pixel), shapes(i,lower_pixel + 1)],...
                lower_pixel);
        else
            predicted = shapes(i,lower_pixel);
        end
        errors(i,j) = abs(actual-predicted)/actual * 100;
    end
end

mean_errors = nanmean(errors,1);

figure('Name','Percentage error of combined models');
hold on;
xlabel('Pixel value');
ylabel('Percentage error');
xlim([0,1022]);
ylim([0,10]);
for i = 1:num_pixels
    plot(pixels(i,:),errors(i,:),'x');
end
plot(pixels(5,:),mean_errors,'k-','LineWidth',3);
plot([0,1022],[4,4],'k-.','LineWidth',3);
% plot combined models and crossover points
for i = 1:num_pixels
    figure('Name',['Pixel response ',num2str(i)]);
    hold on;
    title(['Pixel ',num2str(i),'response']);
    xlabel('Pixel value');
    ylabel('Light intensity cd/m2');
    xlim([0,1022]);
    original_plot = plot(pixels(i,:),light_level,'x');
    if ~isnan(model_crossovers(i))
        linear_end = model_crossovers(i) - linear_shifts(i);
        non_linear_end = model_crossovers(i) - non_linear_shifts(i);
        linear_plot = plot(linear_eff_pixels(i,1:linear_end),linear_model(1:linear_end));
        non_linear_plot = plot(non_linear_eff_pixels(i,non_linear_end:end),non_linear_model(non_linear_end:end)-vertical_shifts(i));
        annotation_string = ['Linear shift: ',num2str(linear_shifts(i)),char(10),...
            'Non-linear shift: ',num2str(non_linear_shifts(i)),char(10),...
            'Vertical shift: ',num2str(vertical_shifts(i)),char(10),...
            'Crossover pixel: ',num2str(model_crossovers(i))];
        annotation('textbox',[0.2,0.5,0.18,0.11],'String',annotation_string)
    end
    error_plot = plot(pixels(i,:),errors(i,:),'x');
    error_aim_plot = plot([0,1022],[4,4],'k-.','LineWidth',3);
    
    legend('Original data','Linear model','Non-linear model','Model errors','4% error aim','Location','NorthWest');
end

