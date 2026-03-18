function new_pos = move_to_target(map, robot_pos, target)
    map = int8(map);
    
    queue = zeros(45366,2);

    front = 1; % Front of the queue
    rear = 1;  % Rear of the queue = next index

    current_pos = robot_pos;

    queue(rear, :) = current_pos;
    rear = rear + 1;

    map(current_pos(1), current_pos(2)) = 99; %99 indicates start

    while front ~= rear
        current_pos = queue(front, :);
        front = front + 1;

        if isequal(current_pos, target)
            break;
        end

        dirs = [-1 0; 1 0; 0 -1; 0 1];

        for i = 1:4
            neighbor = current_pos + dirs(i,:);

            if map(neighbor(1), neighbor(2)) == 0
                queue(rear,:) = neighbor;
                rear = rear + 1;
        
                map(neighbor(1),neighbor(2)) = -i;
            end
        end
    end

    previous_dir = 0;
    while ~isequal(current_pos, robot_pos)
        previous_dir = map(current_pos(1), current_pos(2));
        
        % Trace back to the robot's position
        switch previous_dir
            case -1
                current_pos = current_pos + [1, 0];
            case -2
                current_pos = current_pos + [-1, 0];
            case -3
                current_pos = current_pos + [0, 1];
            case -4
                current_pos = current_pos + [0, -1];
        end            
    end

    % Trace back to the robot's position
    switch previous_dir
        case -1
            new_pos = current_pos + [-1, 0];
        case -2
            new_pos = current_pos + [1, 0];
        case -3
            new_pos = current_pos + [0, -1];
        case -4
            new_pos = current_pos + [0, 1];
        otherwise
            new_pos = robot_pos;
    end
end

