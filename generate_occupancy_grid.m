img = imread('data/path_map.png');

bw = imbinarize(img(:, :, 1), 0.5);

bw = bw(283:end, :);

map = occupancyMap(bw, 0.7634);

show(map);
title('Occupancy Grid');

save('occupancyGridMap.mat', 'map');