function flag = helperIsNodeLegal(obj, point)
    types = cellstr(["agents", "circleBlock", "polygonBlock"]);
    for i = 1:length(types)
        type = types{i};
        if isfield(obj.neighbour, type) == true
            listNN = obj.neighbour.(type);
            for j = 1:length(listNN)
                if norm(point - listNN(j).position) <= listNN(j).radius
                    flag = false;
                    return;
                end
            end
        end
    end
    flag = true;
end
