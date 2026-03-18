function move_from_to(from, to)
    load("occupancyGridMap.mat");
    
    % scale factor 1.30979 
    % conversion = x*sf, (1053-y)*sf
    
    names = ["Marshgate";"One Pool Street";"Itsu";"Waitrose";"McDonalds";"Caffe Nero";"Greggs";"P1";"P2";"P3";"P4";"P5";"P6";"P7";"P8";"P9";"P10"];
    
    % Data: [x y lat lon type]
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
    
    lat = data(:,3);
    lon = data(:,4);
    type = data(:,5);
    
    % Separate the two groups
    lat1 = lat(type==1);
    lon1 = lon(type==1);
    
    lat0 = lat(type==0);
    lon0 = lon(type==0);
    
    % Create geographic plot
    geoscatter(lat1,lon1,80,'red','filled')
    hold on
    geoscatter(lat0,lon0,80,'blue','filled')
    geobasemap streets
    title('Location Map')

    % Add labels
    for i = 1:length(names)
        text(lat(i),lon(i),names{i},'FontSize',8)
    end

    idx_from = names == from;
    idx_to = names == to;
    
    robot_pos = data(idx_from, 1:2);
    target = data(idx_to, 1:2);
    
    [robot_pos(1), robot_pos(2)] = deal(robot_pos(2), robot_pos(1));
    [target(1), target(2)] = deal(target(2), target(1));
    
    p = geoscatter(-0.000006539212292*robot_pos(1) + 51.544470183547240, 0.000010653595386*robot_pos(2) -0.016781643846851, 120,'green','filled');
    
    legend('Main Points','Passing Points', 'Robot')

    while ~isequal(robot_pos, target)
        robot_pos = move_to_target(bw, robot_pos, target);
        p.XData = -0.000006539212292*robot_pos(1) + 51.544470183547240;
        p.YData = 0.000010653595386*robot_pos(2) -0.016781643846851;
        pause(0.01); % Pause for visualization
    end
    
    hold off
end