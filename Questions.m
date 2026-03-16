%% --- INITIALIZATION ---
% 1. Prompt user for the target point name
target_name = input('Enter the name of the point to search from: ', 's');

% 2. Find the exact point in the dataset (case-insensitive)
target_idx = find(strcmpi(names, target_name), 1);

if isempty(target_idx)
    fprintf('Error: Point "%s" not found in the dataset.\n', target_name);
    return;
end

% Extract target coordinates [Lon, Lat]
target_point = [lon(target_idx), lat(target_idx)];

% Define average walking speed
walking_speed_mps = 1.4; % meters per second


%% --- SECTION 1: FIND THE SINGLE CLOSEST POINT ---
fprintf('\n=========================================\n');
fprintf('        SINGLE CLOSEST POINT\n');
fprintf('=========================================\n');

% Call search_knn and ask for exactly 1 neighbor (k = 1)
[closest_node_1, ~] = search_knn(tree, target_point, 0, cell(1,0), [], 1);

if ~isempty(closest_node_1)
    node = closest_node_1{1}; 
    
    if isstring(node.point) || ischar(node.point)
        node_coords = double(string(node.point));
    else
        node_coords = node.point;
    end
    
    % Calculate distance and time
    dist_meters = haversine_dist(target_point(2), target_point(1), node_coords(2), node_coords(1));
    time_seconds = dist_meters / walking_speed_mps;
    time_mins = floor(time_seconds / 60);
    time_secs = round(mod(time_seconds, 60));
    
    fprintf('Target Point : %s\n', target_name);
    fprintf('Closest Point: %s\n', node.name);
    fprintf('Distance     : %.2f meters\n', dist_meters);
    
    % Print time cleanly (handle 0 minutes case)
    if time_mins > 0
        fprintf('Walking Time : %d min %d sec\n', time_mins, time_secs);
    else
        fprintf('Walking Time : %d seconds\n', time_secs);
    end
else
    fprintf('No closest point found.\n');
end


%% --- SECTION 2: FIND THE TOP 3 CLOSEST POINTS ---
fprintf('\n=========================================\n');
fprintf('          TOP 3 CLOSEST POINTS\n');
fprintf('=========================================\n');

% Call the EXACT same function, but ask for 3 neighbors (k = 3)
[closest_nodes_3, ~] = search_knn(tree, target_point, 0, cell(1,0), [], 3);

if ~isempty(closest_nodes_3)
    for i = 1:length(closest_nodes_3)
        node = closest_nodes_3{i};
        
        if isstring(node.point) || ischar(node.point)
            node_coords = double(string(node.point));
        else
            node_coords = node.point;
        end
        
        % Calculate distance and time
        dist_meters = haversine_dist(target_point(2), target_point(1), node_coords(2), node_coords(1));
        time_seconds = dist_meters / walking_speed_mps;
        time_mins = floor(time_seconds / 60);
        time_secs = round(mod(time_seconds, 60));
        
        % Format the output string depending on if it takes > 1 minute
        if time_mins > 0
            time_str = sprintf('%d min %d sec', time_mins, time_secs);
        else
            time_str = sprintf('%d sec', time_secs);
        end
        
        fprintf('%d. %s\n   Distance: %.2f m | Walk Time: %s\n', i, node.name, dist_meters, time_str);
    end
else
    fprintf('No closest points found.\n');
end
fprintf('\n');


%% =========================================================================
% LOCAL FUNCTIONS (Shared by all sections above)
% =========================================================================

function [best_nodes, best_dists] = search_knn(node, target, depth, best_nodes, best_dists, k)
    if isempty(node)
        return;
    end
    
    if isstring(node.point) || ischar(node.point)
        current_point = double(string(node.point));
    else
        current_point = node.point;
    end
    
    dist = sqrt((target(1) - current_point(1))^2 + (target(2) - current_point(2))^2);
    
    if dist > 1e-9
        best_dists(end+1) = dist;
        best_nodes{end+1} = node;
        
        [best_dists, sort_idx] = sort(best_dists);
        best_nodes = best_nodes(sort_idx);
        
        if length(best_dists) > k
            best_dists = best_dists(1:k);
            best_nodes = best_nodes(1:k);
        end
    end
    
    axis_k = 2;
    axis = mod(depth, axis_k) + 1;
    axis_diff = target(axis) - current_point(axis);
    
    if axis_diff < 0
        first_branch = node.left;
        second_branch = node.right;
    else
        first_branch = node.right;
        second_branch = node.left;
    end
    
    [best_nodes, best_dists] = search_knn(first_branch, target, depth + 1, best_nodes, best_dists, k);
    
    if length(best_dists) < k
        worst_dist = inf;
    else
        worst_dist = best_dists(end);
    end
    
    if abs(axis_diff) < worst_dist
        [best_nodes, best_dists] = search_knn(second_branch, target, depth + 1, best_nodes, best_dists, k);
    end
end

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