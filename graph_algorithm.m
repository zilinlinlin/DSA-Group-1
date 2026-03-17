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
         "Caffè Nero", ...
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

%%Question 10 - Is A or B closer to me?
function currentPosition = question10(graph, startNode, pointA, pointB)
    distance_from_A = question2(graph, startNode, pointA);
    distance_from_B = question2(graph, startNode, pointB);
    fprintf("Distance to %s: %.2fm\n", pointA, distance_from_A);
    fprintf("Distance to %s: %.2fm\n", pointB, distance_from_B);
    if (distance_from_A > distance_from_B)
       fprintf("%s is closer. Here is how to get to %s:", pointA, pointA);
       question1(graph, startNode, pointA);
       currentPosition = pointA;
    else
       fprintf("%s is closer. Here is how to get to %s: ", pointB, pointB);
       question1(graph, startNode, pointB);
       currentPosition = pointB;
    end
end
function currentPosition = prompt_question10(graph, currentPosition)
    pointA = string(input("Is...","s"));
    pointB = string(input("or... ","s"));
    fprintf("closer to me?\n");
    fprintf("Is %s or %s closer to me?\n", pointA, pointB);
    fprintf("You are currently at %s\n", currentPosition);
    currentPosition = question10(graph, currentPosition, pointA, pointB);
end
%%main
disconnect = false;
currentPosition = "Marshgate"; %starts at Marshgate
while ~disconnect
    question = input("Hi! I'm your very trustworthy navigation robot. What would you like to ask me?\n1) (Traverse) How do I get from ... to ...?\n2) (Info) What is the shortest distance from ... to ...?\n3) (Info) What is the estimated time from ... to ...?\n7) (Traverse) How do I get back to the nearest waiting point?\n8) (Traverse) Take me anywhere!\n10) (Traverse) Is A or B closer to me?\nChoose a question: ");
    
    if (question == 1)
        currentPosition = prompt_question1(graph);
    else 
        if (question == 2)
            prompt_question2(graph);
        else
            if (question == 3)
                prompt_question3(graph);
            else
                if (question == 7)
                    currentPosition = prompt_question7(graph, currentPosition);
                else
                    if (question == 8)
                        currentPosition = prompt_question8(graph, currentPosition);
                    else
                        if (question == 10)
                            currentPosition = prompt_question10(graph, currentPosition);
                        end
                    end
                end
            end
        end
    end
    ask = string(input("\nAsk another question?(Yes/No): ","s"));
    if (ask == "No")
       fprintf("Bye bye!");
       disconnect = true;
    end
end
