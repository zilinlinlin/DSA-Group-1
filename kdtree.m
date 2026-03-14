function node = build_kdtree(points, depth)
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
    name = sorted_points(median_idx, 3);
    
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
    
    left_points = sorted_points(1 : median_idx-1, :);
    right_points = sorted_points(median_idx+1 : end, :);
    
    node.left = build_kdtree(left_points, depth + 1);
    node.right = build_kdtree(right_points, depth + 1);
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
nodes = [Lon,Lat,Name];
tree = build_kdtree(nodes, 0);
print_kdtree(tree);

