function [error, errMsg] = mapSanityCheck(map)
%MAPSANITYCHECK 
    error = false;
    errMsg = "";
    
    % map boundary check
    boundary = map.boundary;
    if boundary(1) > boundary(2) || boundary(3) > boundary(4)
        error = true;
        errMsg = 'Sanity Check Failed: Map boundary error';
    end
    
    % agent2agent position check
    agent = map.agent;
    if isempty(agent)
        error = true;
        errMsg = 'Sanity Check Failed: No agents in the environment';
    else
        for i = 1:size(agent, 1)
           for j = 1:size(agent, 1)
              if i ~= j
                  r_i = agent(i,5);
                  r_j = agent(j,5);
                  pos_i = agent(i,1:2);
                  pos_j = agent(j,1:2);
                  goal_i = agent(i, 6:7);
                  goal_j = agent(j, 6:7);
                  if norm(pos_i - pos_j) < (r_i + r_j)
                      error = true;
                      errMsg = ['Sanity Check Failed: initial position' ...
                          ' overlapped. Index:' num2str(i) ' and ' num2str(j)];
                  elseif norm(goal_i - goal_j) < (r_i + r_j)
                      error = true;
                      errMsg = ['Sanity Check Failed: goal position' ...
                          ' overlapped. Index:' num2str(i) ' and ' num2str(j)];
                  end
              end
           end
        end
    end
    
    % agent2circleObstacle position check
    circleObs = map.circleBlock;
    if ~isempty(circleObs)
        for i = size(agent, 1)
            for j = size(circleObs, 1)
                r_i = agent(i,5);
                r_j = circleObs(j,5);
                pos_i = agent(i,1:2);
                pos_j = circleObs(j,1:2);
                if norm(pos_i - pos_j) < (r_i + r_j)
                    error = true;
                    errMsg = ['Sanity Check Failed: initial position' ...
                        ' overlapped with obstacle. Index:' num2str(i)];
                end
            end
        end
    end
end
