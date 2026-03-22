%%CONVERSATION
%detect places as keywords
function detected_places = detect_places(graph, sentence)

    detected_places = strings(0);  % string array to store detected place names
    sentence_clean = lower(strrep(sentence, "'", "")); % handle names like McDonald's

    ptr = graph;

    while ~isempty(ptr)
        placeName = lower(strrep(ptr.Name, "'", "")); % normalize name

        if contains(sentence_clean, placeName)
            detected_places(end+1) = ptr.Name; % keep original name
        end

        ptr = ptr.Next;
    end
end

%processes keywords of conversation
function [conversation_end, currentPosition, mentionedPlaces] = process_speech(graph, tree, names, lat, lon, sentence, currentPosition, startPosition, mentionedPlaces)
    conversation_end = false;
    sentence = lower(sentence);
     detected = detect_places(graph, sentence);
    if ~isempty(detected)
        fprintf("ROBOT: ");
        fprintf("\nI heard %s\n", detected);
        mentionedPlaces = [mentionedPlaces, detected]; 
    end
    if contains(sentence, "westfield")
        detected = "P5";
        mentionedPlaces = [mentionedPlaces, detected]; 
    end
    %Let's go to ___
    if ~isempty(mentionedPlaces) && any(contains(sentence, "go to"));
        fprintf("ROBOT: ");
        fprintf("\nCalculating route to %s...", detected);
        currentPosition = question1(graph, currentPosition,  string(mentionedPlaces{end}));
    end
    %Closest places
    if contains(sentence, "closest places") &&  ~isempty(mentionedPlaces)
        fprintf("ROBOT: ");
        fprintf("\nFinding closest places...");
        closest_points = question6(tree, names, lat, lon, currentPosition);
        for i = 1:length(closest_points)
        node = closest_points{i};
            if ismember(node.name, names(1:7)) && ~strcmp(node.name, currentPosition)
                mentionedPlaces = [mentionedPlaces, node.name];
            end
        end
    end
    %How far
     if contains(sentence, "how far") &&  ~isempty(mentionedPlaces)
        fprintf("ROBOT: ");
        fprintf("\nCalculating distance to %s...",   mentionedPlaces{end});
        shortest_distance = question2(graph, currentPosition,   mentionedPlaces{end});
        fprintf("ROBOT: ");
        fprintf("\nShortest distance to %s is %.2fm. ", mentionedPlaces{end}, shortest_distance);
     end
    %Comparing places
    if contains(sentence, "closer") && numel(mentionedPlaces) >= 2
        placeA = mentionedPlaces{end-1}; 
        placeB = mentionedPlaces{end};
        fprintf("ROBOT: ");
        fprintf("\nComparing options: %s vs %s...\n", placeA, placeB);
        question10(graph, currentPosition, placeA, placeB);
    end
    %return time
    if contains(sentence, "how long") && ~isempty(mentionedPlaces)
        fprintf("ROBOT: ");
        fprintf("\nCalculating return time...\n");
        shortest_distance = question2(graph, currentPosition, startPosition);
        walking_speed_mps = 1.4; % meters per second
        shortest_time_mins = round(shortest_distance/walking_speed_mps/60, 0);
        shortest_time_seconds = rem(shortest_distance/walking_speed_mps, 60);%remaining seconds
        fprintf("ROBOT: ");
        fprintf("Estimated time from %s to %s is %.0f minutes %.0f seconds\n", currentPosition, startPosition, shortest_time_mins, shortest_time_seconds);
    end
    %return to initial place
    if contains(sentence, "back")
        fprintf("ROBOT: ");
        fprintf("\nReturning to %s...\n", startPosition);
        currentPosition = question1(graph, currentPosition, startPosition);
    end
    %robot goes back to waiting point
    if contains(sentence, "return")  && contains(sentence, "own")
        fprintf("ROBOT: ");
        fprintf("\nFinding nearest waiting point...\n");
        currentPosition = question7(graph, currentPosition);
    end
    %describe place
    if contains(sentence, "have?") && ~isempty(mentionedPlaces)
        fprintf("ROBOT: ");
        fprintf("\nAbout %s and %s...\n", mentionedPlaces{end}, mentionedPlaces{end-1});
        fprintf("ROBOT: ");
        question9(mentionedPlaces{end});
        fprintf("ROBOT: ");
        question9(mentionedPlaces{end-1});
    end
    %bye detected
    if contains(sentence, "bye ")
        fprintf("ROBOT: ");
        fprintf("Goodbye, until next time!");
        conversation_end = true;
    end
end


conversation = {
    0, "Noah", "I haven't eaten all day guys. I might grab something at Waitrose.";
    3, "Wyatt", "I don't wanna walk too much. How far away is it?";
    6, "Zi Lin", "Yeah that's way too far. Where do we go now guys?";
    9, "Keira", "I don't know, whichever is closest?";
    12, "Noah", "Let's just go to Westfield and find the closest places to us then.";
    15, "Wyatt", "What do these places even have?";
    18, "Keira", "Greggs sounds good.";
    21, "Noah", "I lowkey want Cafe Nero though.";
    24, "Zi Lin", "Alright, we'll head to whichever is closer.";
    27, "Noah", "Fine, let's go to Greggs then."
    30, "Noah", "Man, that was delicious. What time is it now guys?";
    33, "Wyatt", "Oh my goodness we're gonna be late!";
    36, "Keira", "How long is it gonna take for us to get back???";
    39, "Zi Lin", "We gotta run!";
    42, "Noah", "What about the robot?";
    45, "Keira", "Can it even return on its own?";
    48, "Wyatt", "Oh wow it really can.";
    51, "Zi Lin", "Bye dude!";
};

startPosition = "Marshgate";
currentPosition = "Marshgate";
conversation_end = false;
fprintf("Robot is listening...\n");
i = 0;
start_time = tic;
mentionedPlaces = {};  % empty cell array to store mentioned places
while ~conversation_end
    i = i + 1;
    timestamp = conversation{i,1};
    speaker = conversation{i,2};
    sentence = conversation{i,3};

    % simulate real-time delay
    while toc(start_time) < timestamp
    end

    fprintf("\n[%ds] %s: %s\n", timestamp, speaker, sentence);

    % robot processes speech
    
    [conversation_end, currentPosition, mentionedPlaces] = process_speech(graph, tree, names, lat, lon, sentence, currentPosition, startPosition, mentionedPlaces);

end

fprintf("\nConversation ended.\n");
