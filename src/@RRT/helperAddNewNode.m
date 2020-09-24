function [s, search_finished, newNode] = helperAddNewNode(obj, q_rand)
    checkNum = 10;
    margin = 1;
    search_finished = false;
    d = intmax;
    
    for i = 1:size(obj.vertices, 1)
        tmp = norm(q_rand - obj.vertices(i,:));
        if tmp < d
            d = tmp;
            parent_idx = i;
        end
    end
    nearCdt = obj.vertices(parent_idx, :); % nearest node candidate
    vector = q_rand - nearCdt;
    theta = atan2(vector(2), vector(1));
    newNode = nearCdt + obj.step*[cos(theta) sin(theta)];
    
    % new node boundary check
    if newNode(1) <= obj.map.boundary(1) || newNode(1) >= obj.map.boundary(2) || ...
            newNode(2) <= obj.map.boundary(3) || newNode(2) >= obj.map.boundary(4) || ...
                obj.helperIsNodeLegal(newNode) == false
        s = false;
        return;
    end
    
    % edge legality check
    delta = (newNode-nearCdt)/checkNum;
    for i = 1:checkNum
        point = nearCdt + i*delta;
        if obj.helperIsNodeLegal(point) == false
            s = false;
            return;
        end
    end
    
%     disp(parent_idx)
    
    % add this new node to the tree, use nearest candidate as parent
    newV = [obj.vertices; newNode];
    newID = size(obj.vertices, 1) + 1;
    newValue = [obj.edge(num2str(parent_idx)) newID];
    key = num2str(parent_idx);
    
    obj.vertices = newV;
    obj.edge(num2str(newID)) = [];
    obj.edge(key) = newValue;
    
    % local search finished
    if norm(newNode - obj.start) >= obj.search_radius - margin
       search_finished = true;
    end
    
    s = true;
end