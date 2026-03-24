img = imread('data/path_map.png');

bw = imbinarize(img(:, :, 1), 0.5);

bw = bw(283:end, :);

map = occupancyMap(bw, 0.7634);

show(map);
title('Occupancy Grid');

save('occupancyGridMap.mat', 'map', "bw");

data = [
    495 1020 51.5378 -0.01152 1
    615 914 51.5385 -0.01022 1
    687 406 51.5418 -0.00947 1
    753 104 51.5438 -0.00876 1
    1019 134 51.5436 -0.00596 1
    1083 267 51.5427 -0.00525 1
    1111 215 51.5431 -0.00495 1
    476 965 51.5382 -0.01172 0
    437 598 51.5405 -0.01215 0
    518 524 51.541 -0.01122 0
    778 917 51.5385 -0.00852 0
    758 362 51.5421 -0.00873 0
    940 559 51.5408 -0.00676 0
    866 271 51.5427 -0.00756 0
    932 96 51.5438 -0.00677 0
    1171 288 51.5426 -0.00433 0
    1066 172 51.5433 -0.0054 0
    ];

hold on

% scale factor 1.30979 
% conversion = x*sf, (1053-y)*sf

sf = 1.30979; % Define the scale factor for conversion

lat = data(:, 2);
lon = data(:, 1);
type = data(:, 5);

lat1 = lat(type==1);
lon1 = lon(type==1);

lat0 = lat(type==0);
lon0 = lon(type==0);

% Create geographic plot
scatter(lon1*sf,(1053-lat1)*sf,80,'red','filled')
scatter(lon0*sf,(1053-lat0)*sf,80,'blue','filled')
