%% init function
% @Input: ENV filename
% @Output: CONFIGURATION for simulation

% Author: Lu, Hong (luh.lewis@gmail.com)

function CONFIG =  envInit(filename)
    type("util/logo.txt");

    %% LOAD ENVIRONMENT
    CONFIG.filename = filename;
    CONFIG.videoName = CONFIG.filename;
    filename = strcat("maps/", filename, ".txt");
    fid = fopen(filename, 'rt');
    C = textscan(fid,'%s'); % return CELL for the 

    %% INDEX RECORD
    idx_boundary        = 0;
    idx_adjMatrix       = 0;
    idx_formation       = 0;
    idx_deltaT          = 0;
    num_phase           = 1; % default value for phase is 1
    idx_circleBlock     = [];
    idx_polygonBlock    = [];
    idx_agent           = [];
    idx_goal            = [];
    idx_displacement    = [];

    %%     KEYWORD TABLE
    %     ---------------------
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
    %     ---------------------

    for i = 1:length(C{1})
        if strcmp(C{1}{i},      'boundary')
            idx_boundary            = i;
        elseif strcmp(C{1}{i},  'agent')
            idx_agent(end+1)        = i;
        elseif strcmp(C{1}{i},  'mode') % agent generation mode
            CONFIG.mode             = C{1}{i+1};
        elseif strcmp(C{1}{i},  'quantity')
            CONFIG.quantity         = str2double(C{1}{i+1});            
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
            idx_formation           = i;            
        elseif strcmp(C{1}{i},  'displacementMatrix')
            idx_displacement(end+1) = i;
        elseif strcmp(C{1}{i},  'deltaT')
            idx_deltaT              = i;
        end
    end

    %% ENVIRONMENT EXTRACTION
    % store boundary into map structure
    dim                 = 2;
    circleBlockInfo     = 5;
    polygonBlockInfo    = 4;
    agentInfo           = 5;

    CONFIG.dim          = dim;
    CONFIG.boundary     = zeros(1,2*dim);
    CONFIG.deltaT       = str2double(C{1}{idx_deltaT+1});
    CONFIG.phase        = num_phase;

    % store boundary into map structure
    fprintf("[INFO]\t LOADING BOUNDARY INFO...\n");
    CONFIG.boundary = zeros(1,2*dim);
    for i = idx_boundary+1: idx_boundary+2*dim
        CONFIG.boundary(1,i-idx_boundary) = str2double(C{1}{i});
    end
    
    % temporary variables
    tmp.deltaT  = CONFIG.deltaT;
    tmp.dim     = CONFIG.dim;    
    
    % store circleBlock into map structure
    tmp.circleBlock = zeros(length(idx_circleBlock),circleBlockInfo);
    fprintf("[INFO]\t LOADING CIRCLE BLOCK INFO...\n");
    if ~isempty(idx_circleBlock)
        for i = 1:length(idx_circleBlock)
            for j = idx_circleBlock(i)+1:idx_circleBlock(i)+circleBlockInfo
                tmp.circleBlock(i,j-idx_circleBlock(i)) = str2double(C{1}{j});
            end
        end
        CONFIG.circleBlock = Obstacle(tmp);
    end
    
    % store polygonBlock into map structure
    tmp.polygonBlock = zeros(length(idx_polygonBlock),polygonBlockInfo);
    fprintf("[INFO]\t LOADING POLYGON BLOCK INFO...\n");
    if ~isempty(idx_polygonBlock)
        for i = 1:length(idx_polygonBlock)
            for j = idx_polygonBlock(i)+1:idx_polygonBlock(i)+polygonBlockInfo
                tmp.polygonBlock(i, j-idx_polygonBlock(i)) = str2double(C{1}{j});
            end
        end
        CONFIG.polygonBlock = Polygon(tmp);
    end

    formation_type = C{1}{idx_formation+1}; % string;
    fprintf("[INFO]\t CONFIGURATION DEFINED %s FORMATION...\n", formation_type);
    CONFIG.formation_type = formation_type;

    %% AGENT GENERATION

    assert(isfield(CONFIG, "mode"), "[ERROR] KEYWORD MODE IS REQUIRED")
    
    switch CONFIG.mode
        case "random"
            fprintf("[INFO]\t %s GENERATION IS ACTIVATED...\n", CONFIG.mode);
            
            assert(isfield(CONFIG, "quantity"), "[ERROR] KEYWORD QUANTITY IS REQUIRED")
            
            random_radius = 10;
            CONFIG.agents = randomInitAgent(random_radius, CONFIG.quantity, CONFIG.deltaT);
            
        case "absolute"
            fprintf("[INFO]\t %s GENERATION IS ACTIVATED...\n", CONFIG.mode);
            assert(~isempty(idx_agent), "[ERROR] NO AGENT CONFIGURATION")
            
            num_agent = length(idx_agent);
            
            fprintf("[INFO]\t USING AGENT CONFIGURATION IN THE TXT...\n");
            tmp.agent = zeros(length(idx_agent),agentInfo);
            CONFIG.agents = Agent.empty(0,num_agent);
            for i = 1:length(idx_agent)
                CONFIG.agents(i) = Agent([str2double(C{1}{idx_agent(i)+1}) str2double(C{1}{idx_agent(i)+2})],...
                                            [str2double(C{1}{idx_agent(i)+3}) str2double(C{1}{idx_agent(i)+4})],...
                                            str2double(C{1}{idx_agent(i)+5}),...
                                            i,...
                                            CONFIG.deltaT);
            end
    end
    
    num_agent = length(CONFIG.agents);
    CONFIG.trajectory.agents    = double.empty(0, 2*num_agent);
    CONFIG.buffer.agents        = zeros(1, 2*num_agent);
    
%% GOAL SETTING
    switch CONFIG.formation_type
        case "none"
            switch CONFIG.mode
                case "random"
                    % random mode defaultly set goal as inverse position
                    for i = 1:num_agent
                        CONFIG.agents(i).goal = -CONFIG.agents(i).position;
                    end
                case "absolute"
                    num_goal    = length(idx_goal);
                    assert(isequal(num_goal, num_agent), "[ERROR] GOAL NUM SHOULD BE THE SAME WITH AGENT NUMBER");
                    for i = 1:num_agent
                        CONFIG.agents(i).goal = [str2double(C{1}{idx_goal(i)+1}) str2double(C{1}{idx_goal(i)+2})];
                    end
            end
        case "displacement"
            fprintf("[INFO]\t FORMATION LEADER DEFAULTLY SET AS FIRST ONE...\n");
            fprintf("[INFO]\t FORMATION HAS %d PHASES...\n", num_phase);
            
            num_goal = length(idx_goal);
            num_displacement = length(idx_displacement);
            
            % assertion for dimensional check
            % assert if condition is false
            assert(~isequal(CONFIG.phase, 0.0), "[ERROR]PHASE SHOULD BE POSITIVE");
            assert(isequal(num_goal, num_phase), "[ERROR] GOAL DIM SHOULD BE THE SAME WITH PHASE NUMBER");
            assert(isequal(num_displacement, num_phase), "[ERROR] DISPLACEMENT DIM SHOULD BE THE SAME WITH PHASE NUMBER");

            CONFIG.leader_goals     = zeros(num_goal,   CONFIG.dim);
            CONFIG.adjacantMatrix   = zeros(num_agent,  num_agent);
            
            fprintf("[INFO]\t LOADING GOALS FOR FORMATION...\n");
            for i = 1:num_goal
                for j = idx_goal(i)+1:idx_goal(i)+CONFIG.dim
                    CONFIG.leader_goals(i, j-idx_goal(i)) = str2double(C{1}{j});
                end
            end

            fprintf("[INFO]\t LOADING ADJACANT MATRIX FOR FORMATION...\n");
            max_num_neighbour = 0;
            for i = 1:num_agent
                for j = 1:num_agent
                    CONFIG.adjacantMatrix(i, j) = str2double(C{1}{idx_adjMatrix + num_agent*(i-1) + j});
                end
                a = find(CONFIG.adjacantMatrix(i,:) == 1);
                max_num_neighbour = max(max_num_neighbour, length(a));
            end
            
            fprintf("[INFO]\t DISPLACEMENT COLUNM DIM = %d\n", max_num_neighbour*2);
            
            CONFIG.displacementMatrix = zeros(num_agent, max_num_neighbour*2, num_displacement);
            fprintf("[INFO]\t LOADING DISPLACEMENT MATRIX FOR FORMATION...\n");
            for i = 1:num_displacement
                for j = 1:num_agent
                    for k = 1:max_num_neighbour*2
                        CONFIG.displacementMatrix(j,k,i) = str2double(C{1}{idx_displacement(i) + (j-1)*max_num_neighbour*2 + k});
                    end
                end
            end
    end

    % close file identifier
    fclose(fid);
    
    CONFIG.trajectory.circleBlock   = double.empty(0,2);
    CONFIG.trajectory.polygonBlock  = double.empty(0,2);
    CONFIG.buffer.circleBlock       = double.empty(0,2);
    CONFIG.buffer.polygonBlock      = double.empty(0,2);
    
    %% CONFIG PARAMETERS

    CONFIG.optVel           = zeros(1, 2*num_agent);
    
    CONFIG.num_agent        = num_agent;
    
    CONFIG.resFolderPath    = 'result';

    CONFIG.objType          = cellstr(["agents", "circleBlock", "polygonBlock"]);

    CONFIG.simEndFlag       = false;

    CONFIG.simTime          = 0.0;

    CONFIG.timeLimit        = 50.0;

    CONFIG.nearestDist      = double.empty(0, num_agent);

    CONFIG.buffer.nDist     = zeros(1, num_agent);

    CONFIG.timeSeries       = [];

    CONFIG.voMethod         = 'truncated'; % origin or truncated VO

    CONFIG.gamma            = 0.3;

    CONFIG.leader_id        = 1;

    CONFIG.cwdSignal        = 0;

    CONFIG.frame            = 1;
    
    

    
end

%%
function agents = randomInitAgent(r, N, deltaT)
    % randomly init agents in the counterclockwise order in a circle
    agents      = Agent.empty(N,0);
    interval    = (2*pi)/N;
    
    for i = 1:N
        position    = r*[cos(interval*(i-1)) sin(interval*(i-1))];
        radius      = 1;
        agents(end+1) = Agent(position, [0.0 0.0], radius, i, deltaT);
    end
end