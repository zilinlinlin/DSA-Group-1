function move_path(path)
    load("occupancyGridMap.mat");
    
    names = ["Marshgate";"One Pool Street";"Itsu";"Waitrose";"McDonald's";"Caffe Nero";"Greggs";"P1";"P2";"P3";"P4";"P5";"P6";"P7";"P8";"P9";"P10"];
    
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

    obstacle_dest = [288 1171
                    917 778 
                    362 758
                    559 940
                    ];

    car_1 = obstacle_dest(1,:);
    car_2 = obstacle_dest(2,:);
    car_3 = obstacle_dest(3,:);

    car_1_target = 4;
    car_2_target = 4;
    car_3_target = 4;
    
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

    idx_from = names == path(1);
        
    robot_pos = data(idx_from, 1:2);
    [robot_pos(1), robot_pos(2)] = deal(robot_pos(2), robot_pos(1));

    r = geoscatter(-0.000006539212292*robot_pos(1) + 51.544470183547240, 0.000010653595386*robot_pos(2) -0.016781643846851, 120,'green','filled');
    c1 = geoscatter(-0.000006539212292*car_1(1) + 51.544470183547240, 0.000010653595386*car_1(2) -0.016781643846851, 80,'magenta','filled');
    c2 = geoscatter(-0.000006539212292*car_2(1) + 51.544470183547240, 0.000010653595386*car_2(2) -0.016781643846851, 80,'magenta','filled');
    c3 = geoscatter(-0.000006539212292*car_3(1) + 51.544470183547240, 0.000010653595386*car_3(2) -0.016781643846851, 80,'magenta','filled');


    legend('Main Points','Passing Points','Robot','Obstacles')
    
    for i = 1:length(path)-1   
        idx_from = names == path(i);
        idx_to = names == path(i+1);
        
        robot_pos = data(idx_from, 1:2);
        target = data(idx_to, 1:2);
        
        [robot_pos(1), robot_pos(2)] = deal(robot_pos(2), robot_pos(1));
        [target(1), target(2)] = deal(target(2), target(1));
    
        while ~isequal(robot_pos, target)
            if isequal(obstacle_dest(car_1_target,:), car_1)
                if car_1_target == 4
                    car_1_target = randi(4);
                else
                    car_1_target = 4;
                end
            end

            if isequal(obstacle_dest(car_2_target,:), car_2)
                if car_2_target == 4
                    car_2_target = randi(4);
                else
                    car_2_target = 4;
                end
            end

            if isequal(obstacle_dest(car_3_target,:), car_3)
                if car_3_target == 4
                    car_3_target = randi(4);
                else
                    car_3_target = 4;
                end
            end

            car_1 = move_to_target(bw, car_1, obstacle_dest(car_1_target,:));
            c1.XData = -0.000006539212292*car_1(1) + 51.544470183547240;
            c1.YData = 0.000010653595386*car_1(2) -0.016781643846851;
            
            car_2 = move_to_target(bw, car_2, obstacle_dest(car_2_target,:));
            c2.XData = -0.000006539212292*car_2(1) + 51.544470183547240;
            c2.YData = 0.000010653595386*car_2(2) -0.016781643846851;

            car_3 = move_to_target(bw, car_3, obstacle_dest(car_3_target,:));
            c3.XData = -0.000006539212292*car_3(1) + 51.544470183547240;
            c3.YData = 0.000010653595386*car_3(2) -0.016781643846851;

            bw(car_3(2), car_3(1)) = 1;
            bw(car_2(2), car_2(1)) = 1;
            bw(car_1(2), car_1(1)) = 1;

            robot_pos = move_to_target(bw, robot_pos, target);
            r.XData = -0.000006539212292*robot_pos(1) + 51.544470183547240;
            r.YData = 0.000010653595386*robot_pos(2) -0.016781643846851;

            drawnow limitrate
            pause(0.00); % Pause for a brief moment to visualize the movement
        end
    end
    
    hold off
end