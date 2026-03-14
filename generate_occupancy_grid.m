img = imread('data/path_map.png');

bw = imbinarize(imgGray, 0.5);

bw = bw(283:end, :);

map = occupancyMap(bw);

show(map);
title('Pixel-Perfect Occupancy Grid');

save('occupancyGridMap.mat', 'map');