%plotting second data log path
load('walk2.mat')
figure;
geobasemap("streets");
geoplot(Position.latitude, Position.longitude);
title("Second path of data");
