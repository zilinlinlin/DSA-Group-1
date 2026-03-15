% Names
names = {
'Marshgate'
'One Pool Street'
'Itsu'
'Waitrose'
'McDonalds'
'Caffe Nero'
'Greggs'
'P1'
'P2'
'P3'
'P4'
'P5'
'P6'
'P7'
'P8'
'P9'
'P10'
};

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

% Map style
geobasemap streets

title('Location Map')
legend('Main Points','Passing Points')
