%%Initialise adjecency list and graph
function newNode = createNode(nodeName)
    newNode = struct("Name", nodeName, "Connections", [], "Next", []);
end

function newConnection = createConnection(nodeName, weight)
    newConnection = struct("NodeTo", nodeName, "Weight", weight, "Next", []);
end

function list = add_node(list, node)
    % list struct, node struct
    if isempty(list)
        list = node;
    else
        node.Next = list; 
        list = node;
    end
end

function list = add_connection(list, fromNode, toNode, weight)
    if isempty(list)
        return
    end
    if list.Name == fromNode
        conn = createConnection(toNode, weight);

        if isempty(list.Connections)
            list.Connections = conn;
        else
            conn.Next = list.Connections;
            list.Connections = conn;
        end
    else
        list.Next = add_connection(list.Next, fromNode, toNode, weight);
    end
end
function nodePtr = find_node(graph, nodeName)

    nodePtr = graph;

    while ~isempty(nodePtr)
        if nodePtr.Name == nodeName
            return
        end
        nodePtr = nodePtr.Next;
    end

end
nodes = ["Marshgate", ...
         "One Pool Street", ...
         "Itsu", ...
         "Waitrose", ...
         "McDonald's", ...
         "Cafe Nero", ...
         "Greggs", ...
         "P1", ...
         "P2", ...
         "P3", ...
         "P4", ...
         "P5", ...
         "P6", ...
         "P7", ...
         "P8", ...
         "P9", ...
         "P10"];   
Connections = ["Marshgate", "P1", 44.5263, ...
               "P1", "One Pool Street", 136.3424, ...
               "One Pool Street", "P2", 258.7496, ...
               "One Pool Street", "P3",  245.5895, ...
               "One Pool Street", "P4", 83.9197, ...
               "Itsu", "P2", 235.0482, ...
               "Itsu", "P3", 165.8697, ...
               "Itsu", "P5", 38.2499, ...
               "P4", "P6", 294.1837, ...
               "P5", "P6", 191.6893, ...
               "P5", "P7", 105.9421, ...
               "P9", "P6", 248.5135, ...
               "P7", "Waitrose", 147.8088, ...
               "P8", "Waitrose", 144.9587, ...
               "P8", "McDonald's", 59.3594, ...
               "P7", "McDonald's", 149.1913, ...
               "P10", "McDonald's", 52.7022, ...
               "P7", "Caffè Nero", 147.0308, ...
               "P9", "Caffè Nero", 57.1090, ...
               "P9", "Greggs", 38.2287, ...
               "P10", "Greggs", 46.5749];
graph = [];

for i = 1:numel(nodes)
    graph = add_node(graph, createNode(nodes(numel(nodes)-i+1)));
end

for i = 1:3:numel(Connections)
    fromNode = Connections(i);
    toNode   = Connections(i+1);
    weight   = Connections(i+2);

    graph = add_connection(graph, fromNode, toNode, weight);
    graph = add_connection(graph, toNode, fromNode, weight);
end
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
%%Initialise KD Tree
lat = data(:,1);
lon = data(:,2);
type = data(:,3);

names = ["Marshgate";"One Pool Street";"Itsu";"Waitrose";"McDonald's";"Cafe Nero";"Greggs";"P1";"P2";"P3";"P4";"P5";"P6";"P7";"P8";"P9";"P10"];

%%Initialise KD Tree
function node = build_kdtree(points, names, depth)
    % Base Case: No points left to process
    if isempty(points)
        node = [];
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
    name = names(median_idx);
    
    % 4. Create Node
    node = struct(...
        'point', median_point, ...
        'name', name, ...
        'axis', axis, ...
        'left', [], ...
        'right', [] ...
    );
    
    % 5. Recursively Build Subtrees
    % Left: Points BEFORE the median
    % Right: Points AFTER the median
    
    left_points = sorted_points(1:median_idx-1,:);
right_points = sorted_points(median_idx+1:end,:);

left_names = names(1:median_idx-1);
right_names = names(median_idx+1:end);

node.left = build_kdtree(left_points, left_names, depth + 1);
node.right = build_kdtree(right_points, right_names, depth + 1);
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
KDnodes = [lon, lat];
tree = build_kdtree(KDnodes, names, 0);
print_kdtree(tree);

function [best_nodes, best_dists] = search_knn(KDnode, target, depth, best_nodes, best_dists, k)
    if isempty(KDnode)
        return;
    end
    
    if isstring(KDnode.point) || ischar(KDnode.point)
        current_point = double(string(KDnode.point));
    else
        current_point = KDnode.point;
    end
    
    dist = sqrt((target(1) - current_point(1))^2 + (target(2) - current_point(2))^2);
    
    if dist > 1e-9
        best_dists(end+1) = dist;
        best_nodes{end+1} = KDnode;
        
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
        first_branch = KDnode.left;
        second_branch = KDnode.right;
    else
        first_branch = KDnode.right;
        second_branch = KDnode.left;
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
%%QUESTION 1 - How do I get from A to B?

function currentPosition = question1(graph, startNode, endNode)
    fprintf("\nStart from %s\n", startNode);

    % collect node names
    nodeNames = strings(0);
    ptr = graph;
    while ~isempty(ptr)
        nodeNames(end+1) = ptr.Name;
        ptr = ptr.Next;
    end
    n = length(nodeNames);

    dist = inf(1,n);
    visited = false(1,n);
    prev = strings(1,n);

    startIndex = find(nodeNames == startNode);
    dist(startIndex) = 0;

    % priority queue
    pq_nodes = startIndex;
    pq_dist = 0;

    while ~isempty(pq_nodes)
        % extract minimum distance node
        [~, idx] = min(pq_dist);
        u = pq_nodes(idx);

        pq_nodes(idx) = [];
        pq_dist(idx) = [];

        if visited(u)
            continue
        end
        visited(u) = true;

        currentName = nodeNames(u);

        % stop if end node reached
        if currentName == endNode
            break  % break out of while loop to reconstruct path
        end

        nodePtr = find_node(graph, currentName);
        conn = nodePtr.Connections;

        while ~isempty(conn)
            v = find(nodeNames == conn.NodeTo);
            weight = str2double(conn.Weight);

            if dist(u) + weight < dist(v)
                dist(v) = dist(u) + weight;
                prev(v) = currentName;
                % push into priority queue
                pq_nodes(end+1) = v;
                pq_dist(end+1) = dist(v);
            end
            conn = conn.Next;
        end
    end

    %after finding shoprtest path, construct it
    path = endNode;
    current = endNode;
    while current ~= startNode
        idx = find(nodeNames == current);
        if prev(idx) == ""
            fprintf("No path found from %s to %s\n", startNode, endNode);
            return
        end
        current = prev(idx);
        path = [current, path];
    end

    for i = 2:length(path)-1
        if i == length(path)
            fprintf("%s\n", path(i));
        else
            fprintf("then go to %s\n", path(i));
        end
    end
    fprintf("reached %s", endNode);
    currentPosition = endNode;
end
function currentPosition = prompt_question1(graph)
    startNode = string(input("How do I get from... ","s"));
    endNode = string(input("to.. ","s"));
    fprintf("How do I get from %s to %s?", startNode, endNode);
    question1(graph, startNode, endNode);
    currentPosition = endNode;
end

%%Question 2 - What is the shortest distance from A to B?
function distance = question2(graph, startNode, endNode);
    % collect node names
    nodeNames = strings(0);
    ptr = graph;
    while ~isempty(ptr)
        nodeNames(end+1) = ptr.Name;
        ptr = ptr.Next;
    end
    n = length(nodeNames);

    dist = inf(1,n);
    visited = false(1,n);
    startIndex = find(nodeNames == startNode);
    dist(startIndex) = 0;

    % priority queue
    pq_nodes = startIndex;
    pq_dist = 0;

    while ~isempty(pq_nodes)
        % extract minimum distance node
        [~, idx] = min(pq_dist);
        u = pq_nodes(idx);

        pq_nodes(idx) = [];
        pq_dist(idx) = [];

        if visited(u)
            continue
        end
        visited(u) = true;

        currentName = nodeNames(u);

        % stop if end node reached
        if currentName == endNode
            distance = dist(u);
            break  % break out of while loop to reconstruct path
        end

        nodePtr = find_node(graph, currentName);
        conn = nodePtr.Connections;

        while ~isempty(conn)
            v = find(nodeNames == conn.NodeTo);
            weight = str2double(conn.Weight);

            if dist(u) + weight < dist(v)
                dist(v) = dist(u) + weight;
                % push into priority queue
                pq_nodes(end+1) = v;
                pq_dist(end+1) = dist(v);
            end
            conn = conn.Next;
        end
    end
end

function prompt_question2(graph)
    startNode = string(input("What is the shortest distance from... ","s"));
    endNode = string(input("to... ","s"));
    fprintf("\nWhat is the shortest distance from %s to %s?\n", startNode, endNode);
    shortest_distance = question2(graph, startNode, endNode);
    fprintf("Shortest distance from %s to %s is %.2f metres", startNode, endNode, shortest_distance);
end

%%Question 3 - What is the estimated time from A to B?
function prompt_question3(graph)
    startNode = string(input("What is the estimated time from... ","s"));
    endNode = string(input("to... ","s"));
    fprintf("\nWhat is the estimated time from %s to %s?\n", startNode, endNode);
    shortest_distance = question2(graph, startNode, endNode);
    walking_speed_mps = 1.4; % meters per second
    shortest_time_mins = round(shortest_distance/walking_speed_mps/60, 0);
    shortest_time_seconds = rem(shortest_distance/walking_speed_mps, 60);%remaining seconds
    fprintf("Estimated time from %s to %s is %.0f minutes %.0f seconds", startNode, endNode, shortest_time_mins, shortest_time_seconds);
end

%%Question 4 - What is the closest point to A?
function prompt_question4(tree,names,lat,lon)

    target_name = string(input("What is the closest point to... ","s"));

    target_idx = find(strcmpi(names, target_name),1);

    if isempty(target_idx)
        fprintf("Location not found\n");
        return
    end

    target_point = [lon(target_idx), lat(target_idx)];

    [closest_node, ~] = search_knn(tree, target_point, 0, cell(1,0), [], 1);

    node = closest_node{1};

    dist = haversine_dist(lat(target_idx), lon(target_idx), node.point(2), node.point(1));

    fprintf("Closest point to %s is %s\n", target_name, node.name);
    fprintf("Distance: %.2f metres\n", dist);

end
%%Question 5 - What is the estimated time to the closest point from A?
function prompt_question5(tree,names,lat,lon)

    target_name = string(input("Estimated time to the closest point from... ","s"));

    target_idx = find(strcmpi(names, target_name),1);

    if isempty(target_idx)
        fprintf("Location not found\n");
        return
    end

    target_point = [lon(target_idx), lat(target_idx)];

    walking_speed = 1.4;

    [closest_node, ~] = search_knn(tree, target_point, 0, cell(1,0), [], 1);

    node = closest_node{1};

    dist = haversine_dist(lat(target_idx), lon(target_idx), node.point(2), node.point(1));

    time = dist / walking_speed;

    minutes = floor(time/60);
    seconds = round(rem(time,60));

    fprintf("Closest point to %s is %s\n", target_name, node.name);
    fprintf("Estimated time: %d minutes %d seconds\n", minutes, seconds);

end

%%Question 6 - What are the three closest points from A?
function prompt_question6(tree,names,lat,lon)

    target_name = string(input("What are the three closest points from... ","s"));

    target_idx = find(strcmpi(names, target_name),1);

    if isempty(target_idx)
        fprintf("Location not found\n");
        return
    end

    target_point = [lon(target_idx), lat(target_idx)];

    walking_speed = 1.4;

    [closest_nodes, ~] = search_knn(tree, target_point, 0, cell(1,0), [], 3);

    fprintf("Three closest points to %s:\n", target_name);

    for i = 1:length(closest_nodes)

        node = closest_nodes{i};

        dist = haversine_dist(lat(target_idx), lon(target_idx), node.point(2), node.point(1));

        time = dist / walking_speed;

        minutes = floor(time/60);
        seconds = round(rem(time,60));

        fprintf("%d) %s - %.2f metres (%d min %d sec)\n", i, node.name, dist, minutes, seconds);

    end

end
%%Question 7 - How do I get back to the nearest waiting point? (P4 & P7)
function currentPosition = question7(graph, startNode)
    distance_from_p4 = question2(graph, startNode, "P4");
    distance_from_p7 = question2(graph, startNode, "P7");
    fprintf("Distance to P4 (Waiting point 1): %.2fm\n", distance_from_p4);
    fprintf("Distance to P7 (Waiting point 2): %.2fm\n", distance_from_p7);
    if (distance_from_p4 > distance_from_p7)
       fprintf("P7 is closer. Here is how to get to waiting point 2:");
       question1(graph, startNode, "P7");
       currentPosition = "P7";
    else
        fprintf("P4 is closer. Here is how to get to waiting point 1: ");
       question1(graph, startNode, "P4");
       currentPosition = "P7";
    end
end
function currentPosition = prompt_question7(graph, currentPosition)
    fprintf("How do I get back to the nearest point? \n");
    fprintf("You are currently at %s\n", currentPosition);
    currentPosition = question7(graph, currentPosition);
end
%%Question 8 - Take me anywhere!
function currentPosition = prompt_question8(graph, currentPosition)
    rng("shuffle");
    fprintf("Take me anywhere! \n");
    fprintf("You are currently at %s\n", currentPosition);
    random_choice = randi([1 7]);
    disp(random_choice);
    places = ["Marshgate", "One Pool Street", "Itsu", "Waitrose", "McDonald's", "Caffè Nero", "Greggs", "P1", "P2", "P3", "P4", "P5", "P6", "P7","P8", "P9", "P10"];
    random_place = places(random_choice);
    disp(random_place)
    while random_place == currentPosition %makes sure it doesnt choose same place
        rng("shuffle");
        random_choice = randi([1 7]);
        random_place = places(random_choice);
    end
    fprintf("Let's go to %s", random_place);
    currentPosition = question1(graph, currentPosition, random_place);
    currentPosition = random_place;
end

%%Question 9 - I would like to know more about A
function prompt_question9()
target_name = string(input("I would like to know more about..", "s"));
switch target_name
    case "Marshgate"
        disp('--- UCL Marshgate Summary ---');
        disp('- Flagship Building: The massive centerpiece of the new UCL East campus in Stratford, London, opened in 2023.');
        disp('- Collaborative Vibe: Mixes engineering, robotics, architecture, and creative arts in one space to encourage teamwork.');
        disp('- Design & Tech: Features a huge open atrium, high-tech fabrication labs, and top-tier sustainability ratings.');
        disp('- Publicly Accessible: The lower floors are open to the community, featuring a cafe, library, and exhibition spaces.');
        disp('-----------------------------');
        
    case "One Pool Street"
        disp('--- One Pool Street Summary ---');
        disp('- UCL East Hub: The first building to open on the new UCL East campus (2022).');
        disp('- Mixed Use: Combines cutting-edge academic labs, a cinema, and student accommodation on the upper floors.');
        disp('- Key Facilities: Houses the Robotics and Autonomous Systems lab and global ecology spaces.');
        disp('- Community Focus: Features public cafes, art installations, and open collaborative areas.');
        disp('-------------------------------');
        
    case "Itsu"
        disp('--- Itsu Summary ---');
        disp('- Cuisine: Asian-inspired fast food focusing on sushi, salads, and hot noodle/rice bowls.');
        disp('- Vibe: Quick, healthy, and modern. Great for a light lunch between lectures.');
        disp('- Perks: Famous among students for their half-price evening sale to reduce food waste.');
        disp('--------------------');
        
    case "Waitrose"
        disp('--- Waitrose Summary ---');
        disp('- Type: Premium British supermarket located in nearby Westfield Stratford.');
        disp('- Offerings: High-quality groceries, fresh bakery, and a popular lunchtime meal deal.');
        disp('- Vibe: A bit more upmarket, perfect for grabbing fresh ingredients or a nice study snack.');
        disp('------------------------');
        
    case "McDonalds"
        disp('--- McDonalds Summary ---');
        disp('- Type: Classic, globally recognized fast-food chain.');
        disp('- Offerings: Burgers, fries, chicken nuggets, and cheap coffee.');
        disp('- Vibe: Fast, affordable, and incredibly convenient for a quick bite or late-night fuel.');
        disp('-------------------------');
        
    case "Caffe Nero"
        disp('--- Caffe Nero Summary ---');
        disp('- Type: Popular European-style coffee house chain.');
        disp('- Offerings: Premium espresso drinks, hot paninis, and sweet pastries.');
        disp('- Vibe: Cozy and relaxed. A great off-campus spot for a caffeine fix or pulling out a laptop to study.');
        disp('--------------------------');
        
    case "Greggs"
        disp('--- Greggs Summary ---');
        disp('- Type: Iconic, budget-friendly British bakery chain.');
        disp('- Offerings: Famous for sausage rolls, steak bakes, sandwiches, and sweet treats.');
        disp('- Vibe: Casual, cheap, and cheerful. An absolute staple for student life in the UK.');
        disp('----------------------');
    
    otherwise
        disp("Location unavailable")
end
end
%%Question 10 - Is A or B closer to me?
function question10(graph, startNode, pointA, pointB)
    distance_from_A = question2(graph, startNode, pointA);
    distance_from_B = question2(graph, startNode, pointB);
    fprintf("Distance to %s: %.2fm\n", pointA, distance_from_A);
    fprintf("Distance to %s: %.2fm\n", pointB, distance_from_B);
    if (distance_from_A > distance_from_B)
       fprintf("%s is closer.", pointA);
       question2(graph, startNode, pointA);
    else
       fprintf("%s is closer.", pointB);
       question2(graph, startNode, pointB);
    end
end
function prompt_question10(graph, currentPosition)
    pointA = string(input("Is...","s"));
    pointB = string(input("or... ","s"));
    fprintf("closer to me?\n");
    fprintf("Is %s or %s closer to me?\n", pointA, pointB);
    fprintf("You are currently at %s\n", currentPosition);
    question10(graph, currentPosition, pointA, pointB);
end
%%BONUS- SHOW ME A MAP
function display_map(data, lat, lon, type, names)
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
end
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
end
%%main
disconnect = false;
currentPosition = "Marshgate"; %starts at Marshgate
while ~disconnect
    question = input("Hi! I'm your very trustworthy navigation robot. What would you like to ask me?\n1) (Traverse) How do I get from ... to ...?\n2) (Info) What is the shortest distance from ... to ...?\n3) (Info) What is the estimated time from ... to ...?\n4) (Info) What is the closest point to A?\n5) (Info) What is the estimated time to the closest point to A?\n6) (Info) What are the three closest points to A?\n7) (Traverse) How do I get back to the nearest waiting point?\n8) (Traverse) Take me anywhere!\n9) (Info)Tell me more about A\n10) (Info) Is A or B closer to me?\n11) [BONUS] Show me a map!\nChoose a question: ");
    switch question

    case 1
        currentPosition = prompt_question1(graph);

    case 2
        prompt_question2(graph);

    case 3
        prompt_question3(graph);

    case 4
        prompt_question4(tree,names,lat,lon);

    case 5
        prompt_question5(tree,names,lat,lon);

    case 6
        prompt_question6(tree,names,lat,lon);

    case 7
        currentPosition = prompt_question7(graph, currentPosition);

    case 8
        currentPosition = prompt_question8(graph, currentPosition);

    case 9
        prompt_question9();

    case 10
        prompt_question10(graph, currentPosition);

    case 11
        display_map(data, lat, lon, type, names);

    otherwise
        fprintf("Invalid question number\n");
    end
    ask = string(input("\nAsk another question?(Yes/No): ","s"));
    if (ask == "No")
       fprintf("Bye bye!");
       disconnect = true;
    end
end
