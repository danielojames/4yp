pixels = squeeze(pixel_data(10:20,400,6:end-5));

lt = get_lookup_table(pixels,light_level,shape);
uni_pixels = 1:length(shape);

close all;
figure('Name','Shifted-shape');
hold on
for i = 1:min(size(pixels))
    plot(pixels(i,:),light_level,'x','MarkerSize',3);
    plot(uni_pixels+lt(i),shape,'c');
end

% calculate errors
figure('Name','Errors');
hold on
for i = 1:min(size(pixels))
    for j = 1:length(pixels(i,:))
        predicted = interp1(uni_pixels+lt(i),shape,pixels(i,j));
        error(i,j) = 100*abs(predicted-light_level(j))/light_level(j);
    end
    plot(pixels(i,:),error(i,:),'x')
end

errors = mean(error,1);
plot(pixels(4,:),errors,'c','LineWidth',5)
ylim([0,30]);

plot([0,1022],[2,2],'k--','LineWidth',3)
