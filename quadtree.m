clc; close all;

% 1. Split data based on names
is_p_point = startsWith(names, 'P');
is_place = ~is_p_point;   

% Combine into a cell array for the tree structure: [Longitude, Latitude, Name]
my_points_data = [num2cell(lon), num2cell(lat), cellstr(names)];
num_locations = length(lon);

% 2. Build the Quadtree
capacity = 4; % Maximum points per rectangle before it splits
fprintf('Building Quadtree with capacity %d...\n', capacity);
tree = build_quadtree(my_points_data, capacity);

% 3. Visualize the Tree and Points
figure('Name', 'Geographic Quadtree', 'Color', 'w');
hold on;
axis equal;

% Set map boundaries tightly around the GPS data
xlim([min(lon) - 0.002, max(lon) + 0.004]);
ylim([min(lat) - 0.002, max(lat) + 0.002]);

title('Quadtree');
xlabel('Longitude (X)'); 
ylabel('Latitude (Y)');

% Draw the tree rectangles
visualize_quadtree(tree);

plot(lon(is_place), lat(is_place), 'gp', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot(lon(is_p_point), lat(is_p_point), 'r.', 'MarkerSize', 15);

for i = 1:num_locations
    if is_place(i)
        offset_x = 0.0002; offset_y = 0.0001; text_color = [0 0.5 0]; % Greenish text
        f_size = 9; f_weight = 'bold';
    else
        offset_x = 0.0002; offset_y = 0; text_color = 'r'; % Red text
        f_size = 8; f_weight = 'normal';
    end
    
    text(lon(i) + offset_x, lat(i) + offset_y, names(i), ...
        'FontSize', f_size, 'Color', text_color, 'FontWeight', f_weight);
end

hold off;
disp('Visualization complete.');

% QUADTREE FUNCTIONS
function tree_root = build_quadtree(points, capacity)
    % Extract coordinates to find the map boundaries
    if iscell(points)
        coords = cell2mat(points(:, 1:2));
    elseif isstring(points) || ischar(points)
        coords = double(string(points(:, 1:2)));
    else
        coords = double(points(:, 1:2));
    end
    
    % Define the World Boundary [xmin, xmax, ymin, ymax]
    xmin = min(coords(:,1)) - 0.001;
    xmax = max(coords(:,1)) + 0.001;
    ymin = min(coords(:,2)) - 0.001;
    ymax = max(coords(:,2)) + 0.001;
    world_boundary = [xmin, xmax, ymin, ymax];
    
    % Initialize root and insert points
    tree_root = create_quadnode(world_boundary);
    for i = 1:size(points, 1)
        tree_root = insert_quadpoint(tree_root, points(i, :), capacity);
    end
end

function node = insert_quadpoint(node, point_row, capacity)
    % Extract X and Y for boundary checking
    if iscell(point_row)
        pt_x = double(point_row{1});
        pt_y = double(point_row{2});
    else
        pt_x = double(string(point_row(1)));
        pt_y = double(string(point_row(2)));
    end

    % 1. Ignore if point is outside this node's boundary
    if ~in_quadboundary(node.boundary, pt_x, pt_y)
        return; 
    end
    
    % 2. Internal Node: Pass down to children
    if ~isempty(node.children)
        for i = 1:4
            if in_quadboundary(node.children{i}.boundary, pt_x, pt_y)
                node.children{i} = insert_quadpoint(node.children{i}, point_row, capacity);
                break;
            end
        end
        return;
    end
    
    % 3. Leaf Node: Store the entire row
    if isempty(node.points)
        node.points = point_row;
    else
        node.points = [node.points; point_row];
    end
    
    % 4. Subdivide if capacity is exceeded
    if size(node.points, 1) > capacity
        node = subdivide_quadnode(node, capacity);
    end
end

function node = subdivide_quadnode(node, capacity)
    b = node.boundary;
    mid_x = (b(1) + b(2)) / 2;
    mid_y = (b(3) + b(4)) / 2;
    
    % Create 4 Children (NW, NE, SW, SE)
    node.children = cell(1, 4);
    node.children{1} = create_quadnode([b(1), mid_x, mid_y, b(4)]);
    node.children{2} = create_quadnode([mid_x, b(2), mid_y, b(4)]);
    node.children{3} = create_quadnode([b(1), mid_x, b(3), mid_y]);
    node.children{4} = create_quadnode([mid_x, b(2), b(3), mid_y]);
    
    % Redistribute existing points
    old_points = node.points;
    node.points = []; 
    
    for i = 1:size(old_points, 1)
        node = insert_quadpoint(node, old_points(i, :), capacity);
    end
end

function node = create_quadnode(boundary)
    node = struct('boundary', boundary, 'points', [], 'children', []);
end

function inside = in_quadboundary(b, x, y)
    % Allow exact boundary matches
    inside = (x >= b(1) && x <= b(2) && y >= b(3) && y <= b(4));
end

function visualize_quadtree(node)
    if isempty(node)
        return;
    end
    
    % Draw the boundary rectangle
    b = node.boundary;
    width = b(2) - b(1);
    height = b(4) - b(3);
    rectangle('Position', [b(1), b(3), width, height], 'EdgeColor', [0 0.4470 0.7410], 'LineWidth', 1);
    
    % Recursively draw children
    if ~isempty(node.children)
        for i = 1:4
            visualize_quadtree(node.children{i});
        end
    end
end