clear
clc

row = [495
615
687
753
1019
1083
1111
476
437
518
778
758
940
866
932
1171
1066];
lat = [-0.01152
-0.01022
-0.00947
-0.00876
-0.00596
-0.00525
-0.00495
-0.01172
-0.01215
-0.01122
-0.00852
-0.00873
-0.00676
-0.00756
-0.00677
-0.00433
-0.0054]; 

scatter(row, lat);
hold on

z = ones(numel(row), 2);
z(:,2) = row;

A1 = ((z'*z)^-1*z')*lat;
A2 = z\lat; % slash direction matters

% Calculate the fitted values and plot the regression line
fittedValues = z * A1;
plot(row, fittedValues, 'r-');
legend('Data Points', 'Fitted Line');
hold off

grid on
title("Col to Longitude")