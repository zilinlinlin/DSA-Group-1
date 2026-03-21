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
               "P7", "Cafe Nero", 147.0308, ...
               "P9", "Cafe Nero", 57.1090, ...
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
function bfs(graph, startNode, endNode)

    queue = {startNode, 0};
    visited = strings(0);
    totalDist = 0;
    while ~isempty(queue)
        % Dequeue
        currentNode = queue{1,1};
        currentDist = queue{1,2};
        queue(1,:) = [];

        if any(visited == currentNode)
            continue
        end

        visited(end+1) = currentNode;
        fprintf("Visited: %s (distance: %.2f)\n", currentNode, currentDist);
        totalDist = totalDist + currentDist;

        % Stop if end node reached
        if currentNode == endNode
           fprintf("Visited: %s (distance: %.4f)\n", char(currentNode), currentDist);
            fprintf("Total distance traveled: %.4f\n", totalDist);
            return
        end

        % Find current node in graph
        nodePtr = find_node(graph, currentNode);
        conn = nodePtr.Connections;

        % Enqueue neighbors with updated distances
        while ~isempty(conn)
            neighbor = conn.NodeTo;
            weight = str2double(conn.Weight);

            if ~any(visited == neighbor)
                queue(end+1,:) = {neighbor, currentDist + weight};
            end

            conn = conn.Next;
        end
    end

    fprintf("End node not reachable.\n");
end
function dijkstra(graph, startNode, endNode)
    % Collect all node names
    nodeNames = strings(0);
    ptr = graph;
    while ~isempty(ptr)
        nodeNames(end+1) = ptr.Name;
        ptr = ptr.Next;
    end

    n = length(nodeNames);
    dist = inf(1, n);
    visited = false(1, n);

    % Distance to start node = 0
    startIndex = find(nodeNames == startNode);
    dist(startIndex) = 0;

    for i = 1:n
        % Find unvisited node with minimum distance
        minDist = inf;
        u = -1;
        for j = 1:n
            if ~visited(j) && dist(j) < minDist
                minDist = dist(j);
                u = j;
            end
        end

        if u == -1
            break  % All remaining nodes are unreachable
        end

        visited(u) = true;
        currentName = nodeNames(u);

        % Print visited node
        fprintf("Visited: %s\n", currentName);

        % Stop if end node reached
        if currentName == endNode
            fprintf("Reached end node: %s\n", endNode);
            fprintf("Shortest distance to %s : %.4f\n", endNode, dist(u));
            return
        end

        % Update distances to neighbors
        nodePtr = find_node(graph, currentName);
        conn = nodePtr.Connections;
        while ~isempty(conn)
            v = find(nodeNames == conn.NodeTo);
            weight = str2double(conn.Weight);

            if dist(u) + weight < dist(v)
                dist(v) = dist(u) + weight;
            end

            conn = conn.Next;
        end
    end

    fprintf("End node not reachable.\n");
end

function dijkstra_heap(graph, startNode, endNode)

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

        % print visited node
        fprintf("Visited: %s\n", currentName);

        % stop if end node reached
        if currentName == endNode
            fprintf("Reached end node: %s\n", endNode);
            fprintf("Shortest distance to %s : %.4f\n", endNode, dist(u));
            return
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

    fprintf("End node not reachable.\n");

end
bfs(graph, "Marshgate", "Itsu");
dijkstra(graph, "Marshgate", "Itsu");
dijkstra_heap(graph, "Marshgate", "Itsu");
%dijkstra with heap is the best practice as it prioritises minimum element