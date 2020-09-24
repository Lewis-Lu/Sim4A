%% .txt extraction Middleware

function map = loadMap(filename)
    %% file handle
    fid = fopen(filename, 'rt');
    C = textscan(fid,'%s'); % return CELL for the 
    
    %% index record
    idx_boundary        = 0;
    idx_adjMatrix       = 0;
    num_phase           = 0;
    idx_circleBlock     = [];
    idx_polygonBlock    = [];
    idx_agent           = [];
    idx_goal            = [];
    idx_displacement    = [];
    idx_formation       = [];
    
    %%  INDEX 
%%     KEYWORD TABLE
%     boundary
%     circleBlock
%     polygonBlock
%     agent
%     goal
%     mode
%     quantity
%     formation
%     phase
%     adjacantMatrix
%     displacementMatrix
    for i = 1:length(C{1})
        if strcmp(C{1}{i},      'boundary')
            idx_boundary            = i;
        elseif strcmp(C{1}{i},  'agent')
            idx_agent(end+1)        = i;
        elseif strcmp(C{1}{i},  'mode') % agent generation mode
            map.mode                = C{1}{i+1};
        elseif strcmp(C{1}{i},  'quantity')
            map.quantity            = str2double(C{1}{i+1});            
        elseif strcmp(C{1}{i},  'goal')
            idx_goal(end+1)         = i;            
        elseif strcmp(C{1}{i},  'circleBlock')
            idx_circleBlock(end+1)  = i;
        elseif strcmp(C{1}{i},  'polygonBlock')
            idx_polygonBlock(end+1) = i;
        elseif strcmp(C{1}{i},  'adjacantMatrix')
            idx_adjMatrix           = i;
        elseif strcmp(C{1}{i},  'phase')
            num_phase               = str2double(C{1}{i+1});
        elseif strcmp(C{1}{i},  'formation')
            idx_formation(end+1)    = i;            
        elseif strcmp(C{1}{i},  'displacementMatrix')
            idx_displacement(end+1) = i;
        end
    end
    
    %% ENVIRONMENT EXTRACTION
    % store boundary into map structure
    dim             = 2;
    map.dim         = dim;
    map.boundary    = zeros(1,2*dim);
    map.phase       = num_phase;
    
    % store boundary into map structure
    fprintf("[INFO]\t LOADING BOUNDARY INFO...\n");
    for i = idx_boundary+1: idx_boundary+2*dim
        map.boundary(1,i-idx_boundary) = str2double(C{1}{i});
    end
    
    % store circleBlock into map structure
    circleBlockInfo = 5;
    map.circleBlock = zeros(length(idx_circleBlock),circleBlockInfo);
    fprintf("[INFO]\t LOADING CIRCLE BLOCK INFO...\n");
    if ~isempty(idx_circleBlock)
        for i = 1:length(idx_circleBlock)
            for j = idx_circleBlock(i)+1:idx_circleBlock(i)+circleBlockInfo
                map.circleBlock(i,j-idx_circleBlock(i)) = str2double(C{1}{j});
            end
        end
    end
    
    % store polygonBlock into map structure
    polygonBlockInfo = 4;
    map.polygonBlock = zeros(length(idx_polygonBlock),polygonBlockInfo);
    fprintf("[INFO]\t LOADING POLYGON BLOCK INFO...\n");
    if ~isempty(idx_polygonBlock)
        for i = 1:length(idx_polygonBlock)
            for j = idx_polygonBlock(i)+1:idx_polygonBlock(i)+polygonBlockInfo
                map.polygonBlock(i, j-idx_polygonBlock(i)) = str2double(C{1}{j});
            end
        end
    end
    
    %% AGENT EXTRACTION
    if isfield(map, "mode")
        mode = map.mode;
        fprintf("[INFO]\t %s GENERATION IS ACTIVATED...\n", mode);
    else
        fprintf("[INFO]\t RANDOM GENERATION IS NOT ACTIVATED...\n");
        if isempty(idx_agent)
            error("[ERROR] NO AGENT CONFIGURATION");
        else
            fprintf("[INFO]\t USING AGENT CONFIGURATION IN THE TXT...\n");
            agentInfo = 5;
            map.agent = zeros(length(idx_agent),agentInfo);
            for i = 1:length(idx_agent)
                for j = idx_agent(i)+1:idx_agent(i)+agentInfo
                    map.agent(i, j-idx_agent(i)) = str2double(C{1}{j});
                end
            end
        end
        if isempty(idx_goal)
            error("[ERROR] NO GOAL CONFIGURATION");
        else
            fprintf("[INFO]\t CONFIGURATION DEFINED %d PAHSE(s). CHECK IT LATER...\n", num_phase);
        end
    end
    
    %% FORMATION EXTRACTION
    map.formation_type = C{1}{idx_formation(1) + 1}; % FORMATION TYPE
    ft = map.formation_type;
    fprintf("[INFO]\t CONFIGURATION DEFINED %s FORMATION...\n", ft);
    
    if isfield(map, "formation_type") % define formation behavior
        switch map.formation_type
            case "none"
                if ~isfield(map, "mode") % define goals only under non-random situation
                    num_goal = length(idx_goal);
                    num_agent = length(idx_agent);
                    
                    assert(isequal(num_goal, num_agent),...
                        "[ERROR] GOAL NUM SHOULD BE THE SAME WITH AGENT NUMBER");
                    
                    map.goal = zeros(num_agent, map.dim);
                    for i = 1:num_agent
                        for j = idx_goal(i)+1:idx_goal(i)+map.dim
                            map.goal(i, j-idx_goal(i)) = str2double(C{1}{j});
                        end
                    end
                end
            case "displacement"
                fprintf("[INFO]\t FORMATION LEADER DEFAULTLY SET AS FIRST ONE...\n");
                num_agent = length(idx_agent);
                num_goal = length(idx_goal);
                num_displacement = length(idx_displacement);
                
                assert(isequal(num_goal, num_phase),...
                    "[ERROR] GOAL DIM SHOULD BE THE SAME WITH PHASE NUMBER");
                assert(isequal(num_displacement, num_phase),...
                    "[ERROR] DISPLACEMENT DIM SHOULD BE THE SAME WITH PHASE NUMBER");
                
                map.adjMatrix   = zeros(num_agent, num_agent); % adjacant size N*N
                map.goal        = zeros(num_goal, map.dim*num_phase); % goal size
                map.displacement= zeros(num_agent, map.dim*2);
                fprintf("[INFO]\t LOADING ADJACANT MATRIX FOR FORMATION...\n");
                for i = 1:num_agent
                    for j = 1:num_agent
                        map.adjMatrix(i, j) = str2double(C{1}{idx_adjMatrix + num_agent*(i-1) + j});
                    end
                end
                fprintf("[INFO]\t LOADING GOALS FOR FORMATION...\n");
                for i = 1:num_goal
                    for j = idx_goal(i)+1:idx_goal(i)+map.dim*num_phase
                        map.goal(i, j-idx_goal(i)) = str2double(C{1}{j});
                    end
                end
                fprintf("[INFO]\t LOADING DISPLACEMENT MATRIX FOR FORMATION...\n");
                for i = 1:num_displacement
                    for j = idx_displacement(i)+1:idx_displacement(i)+map.dim*2
                        map.displacement(i, j-idx_displacement(i)) = str2double(C{1}{j});
                    end
                end
        end
    end
    % close file identifier
    fclose(fid);
end