function d = haversine_dist(lat1, lon1, lat2, lon2)
    R = 6371000; % Earth's mean radius in meters
    
    phi1 = lat1 * pi/180;
    phi2 = lat2 * pi/180;
    delta_phi = (lat2 - lat1) * pi/180;
    delta_lambda = (lon2 - lon1) * pi/180;
    
    a = sin(delta_phi/2)^2 + cos(phi1) * cos(phi2) * sin(delta_lambda/2)^2;
    c = 2 * atan2(sqrt(a), sqrt(1-a));
    d = R * c; % Distance in meters
end

data = [
51.5378 -0.01152 1
51.5385 -0.01022 1
51.5418 -0.00947 1
51.5438 -0.00876 1
51.5436 -0.00596 1
51.5427 -0.00525 1
51.5431 -0.00495 1
51.5382 -0.01172 0
51.5405 -0.01215 0
51.5410 -0.01122 0
51.5385 -0.00852 0
51.5421 -0.00873 0
51.5408 -0.00676 0
51.5427 -0.00756 0
51.5438 -0.00677 0
51.5426 -0.00433 0
51.5433 -0.00540 0
];

point1 = 7;
point2 = 17;
haversine_dist(data(point1,1),data(point1,2),data(point2,1),data(point2,2))