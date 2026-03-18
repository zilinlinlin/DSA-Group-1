%%Initialise data and KD tree
% Names
names = ["Marshgate";"One Pool Street";"Itsu";"Waitrose";"McDonald's";"Caffe Nero";"Greggs";"P1";"P2";"P3";"P4";"P5";"P6";"P7";"P8";"P9";"P10"];

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
end;
%initialise KD tree
function KDnode = build_kdtree(points, depth)
    % Base Case: No points left to process
    if isempty(points)
        KDnode = [];
        return;
    end

    % 1. Determine Axis based on depth
    % Depth 0 -> Axis 1 (X)
    % Depth 1 -> Axis 2 (Y)
    % Depth 2 -> Axis 1 (X) ...
    k = 2; % Dimensions (2D)
    axis = mod(depth, k) + 1;
    
    % 2. Sort points by the current axis
    % sortrows(points, axis) sorts the matrix based on the column 'axis'
    sorted_points = sortrows(points, axis);
    
    % 3. Find Median
    n = size(sorted_points, 1);
    median_idx = floor(n / 2) + 1; % Selects middle element
    median_point = [sorted_points(median_idx, 1), sorted_points(median_idx, 2)];
    name = sorted_points(median_idx, 3);
    
    % 4. Create Node
    KDnode = struct(...
        'point', median_point, ...
        'name', name, ...
        'axis', axis, ...
        'left', [], ...
        'right', [] ...
    );
    
    % 5. Recursively Build Subtrees
    % Left: Points BEFORE the median
    % Right: Points AFTER the median
    
    left_points = sorted_points(1 : median_idx-1, :);
    right_points = sorted_points(median_idx+1 : end, :);
    
    KDnode.left = build_kdtree(left_points, depth + 1);
    KDnode.right = build_kdtree(right_points, depth + 1);
end
function print_kdtree(tree, indent)
    if nargin < 2
        indent = 0;
    end
    
    if ~isempty(tree)
        % 1. Print Right side first (higher values)
        % Using a consistent increment (e.g., 12) makes it easier to read
        print_kdtree(tree.right, indent + 12);
        
        % 2. Determine split axis label
        if tree.axis == 1
            axis_name = 'Lon';
        else
            axis_name = 'Lat';
        end
        
        % 3. Format the label 
        % Use %.5f for coordinates and %g or %s for Name depending on type
        % We add a visual "connector" symbol (--)
        padding = blanks(indent);
        %label = sprintf('%s|-- [%.5f, %.5f] (Split:%s)', ...
                        %padding, tree.point(1), tree.point(2), axis_name);
        label = sprintf('%s|-- (Node:%s) (Split:%s)', ...
                        padding, tree.name, axis_name);
        
        fprintf('%s\n', label);
        
        % 4. Print Left side (lower values)
        print_kdtree(tree.left, indent + 12);
    end
end
KDnodes = [lon,lat,names];
tree = build_kdtree(KDnodes, 0);
print_kdtree(tree);


function prompt_question4()
% 1. Prompt user for the target point name
target_name = input('Enter the name of the point to search from: ', 's');

% 2. Find the exact point in the dataset (case-insensitive)
target_idx = find(strcmpi(names, target_name), 1);

if isempty(target_idx)
    fprintf('Error: Point "%s" not found in the dataset.\n', target_name);
    return;
end
end


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