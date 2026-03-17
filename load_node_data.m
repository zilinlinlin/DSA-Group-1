% Names
names = ["Marshgate";"One Pool Street";"Itsu";"Waitrose";"McDonalds";"Caffe Nero";"Greggs";"P1";"P2";"P3";"P4";"P5";"P6";"P7";"P8";"P9";"P10"];

% Data: [Latitude Longitude Type]
data = [
51.53780  -0.01155  1
51.53870  -0.00972  1
51.54190  -0.00920  1
51.54380  -0.00876  1
51.54360  -0.00596  1
51.54280  -0.00544  1
51.54300  -0.00490  1
51.53820  -0.01152  0
51.54060  -0.01188  0
51.54080  -0.01082  0
51.53850  -0.00855  0
51.54210  -0.00875  0
51.54090  -0.00676  0
51.54270  -0.00756  0
51.54390  -0.00667  0
51.54270  -0.00463  0
51.54330  -0.00537  0
];

lat = data(:,1);
lon = data(:,2);
type = data(:,3);

% Separate the two groups
lat1 = lat(type==1);
lon1 = lon(type==1);

lat0 = lat(type==0);
lon0 = lon(type==0);

% Create geographic plot
figure
geoscatter(lat1,lon1,80,'red','filled')
hold on
geoscatter(lat0,lon0,80,'blue','filled')

% Add labels
for i = 1:length(names)
    text(lat(i),lon(i),names{i},'FontSize',8)
end
distances = [];
function dist = plot_distance(point1, point2)
hold on
    lat1 = point1(1);
    lon1 = point1(2);
    lat2 = point2(1);
    lon2 = point2(2);
    arclen = distance(lat1,lon1,lat2,lon2);
    dist = deg2km(arclen)*1000; %distance in metres
    midLat = (lat1+lat2)/2;
    midLon = (lon1+lon2)/2;
    
    geoplot([lat1 lat2], [lon1 lon2], 'k-');
    text(midLat,midLon,sprintf('%f m',dist),'FontSize',7, 'FontWeight','normal', 'Color', 'black');
end
% Map style
geobasemap streets
title('Location Map')
legend('Main Points','Passing Points')
%correspond points to data
marshgate = [data(1,1), data(1,2)];
ops = [data(2,1), data(2,2)];
itsu = [data(3,1), data(3,2)];
waitrose = [data(4,1), data(4,2)];
mcdonalds = [data(5,1), data(5,2)];
nero = [data(6,1), data(6,2)];
greggs = [data(7,1), data(7,2)];
p1 = [data(8,1), data(8,2)];
p2 = [data(9,1), data(9,2)];
p3 = [data(10,1), data(10,2)];
p4 = [data(11,1), data(11,2)];
p5 = [data(12,1), data(12,2)];
p6 = [data(13,1), data(13,2)];
p7 = [data(14,1), data(14,2)];
p8 = [data(15,1), data(15,2)];
p9 = [data(16,1), data(16,2)];
p10 = [data(17,1), data(17,2)];
distance = [plot_distance(marshgate, p1);
    plot_distance(p1, ops);
    plot_distance(ops, p2);
    plot_distance(ops, p3);
    plot_distance(ops, p4);
    plot_distance(p2, itsu);
    plot_distance(p3, itsu);
    plot_distance(itsu, p5);
    plot_distance(p5, p6);
    plot_distance(p5, p7)
    plot_distance(p4, p6);
    plot_distance(p6, p9);
    plot_distance(p7, nero);
    plot_distance(p7, mcdonalds);
    plot_distance(p7, waitrose);
    plot_distance(nero, p9);
    plot_distance(p9, greggs);
    plot_distance(greggs, p10);
    plot_distance(waitrose, p8);
    plot_distance(p8, mcdonalds);
    plot_distance(mcdonalds, p10)];
disp(distance); %distance in metres
