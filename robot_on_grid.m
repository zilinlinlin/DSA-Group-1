clear
clc

load("occupancyGridMap.mat");

show(map);
title('Occupancy Grid');
hold on

% scale factor 1.30979 
% conversion = x*sf, (1053-y)*sf

names = ["Marshgate";"One Pool Street";"Itsu";"Waitrose";"McDonalds"; ...
        "Caffe Nero";"Greggs";"P1";"P2";"P3";"P4";"P5";"P6";"P7";"P8";"P9";"P10"];

% Data: [x y Type]
data = [
495   1020  1
615   914   1
687   406   1
753   104   1
1019  134   1
1083  267   1
1111  215   1
476   965   0
437   598   0
518   524   0
778   917   0
758   362   0
940   559   0
866   271   0
932   96    0
1171  288   0
1066  172   0
];

% Convert and plot all data points
scaledX = data(:, 1) * 1.30979;
scaledY = (1053 - data(:, 2)) * 1.30979;
plot(scaledX(data(:, 3) == 1), scaledY(data(:, 3) == 1), 'ro', 'MarkerSize', 5,MarkerFaceColor='r'); % Type 1
plot(scaledX(data(:, 3) == 0), scaledY(data(:, 3) == 0), 'bo', 'MarkerSize', 5,MarkerFaceColor='b'); % Type 0

robot_pos = [495,1020];
target = [1019,134];

[robot_pos(1), robot_pos(2)] = deal(robot_pos(2), robot_pos(1));
[target(1), target(2)] = deal(target(2), target(1));

h = plot(robot_pos(2) * 1.30979,(1053 - robot_pos(1)) * 1.30979, 'go', MarkerSize=8,MarkerFaceColor='g');

while ~isequal(robot_pos, target)
    robot_pos = move_to_target(bw, robot_pos, target);
    % Update the robot's position on the plot
    h.XData = robot_pos(2) * 1.30979;
    h.YData = (1053 - robot_pos(1)) * 1.30979;
    pause(0.01); % Pause for visualization
end

hold off