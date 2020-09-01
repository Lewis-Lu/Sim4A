%% neighbourhood calculation
function [neighbour, s, minDist] = calNN(obj, config)
    minDist = intmax;
    s = 0;
    for i = 1:length(config.objType)
        type = config.objType{i};
        buffer.(type)  = [];
        if isfield(config, type) == true
            listObj = config.(type);
            for j = 1:length(listObj)
                dist = norm(obj.position - listObj(j).position);
                if dist < minDist && dist ~= 0
                    minDist = dist;
                end
                if dist > obj.measurementRadius || dist == 0
                    continue
                end
                buffer.(type) = [buffer.(type) listObj(j)];
            end
        end
        neighbour.(type) = buffer.(type);
    end
end