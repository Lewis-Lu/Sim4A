 %% class definition file for 'Agent'
% 
% Written by Lu, Hong
% luhong@westlake.edu.cn
% 

classdef Agent
    %% PROPERTIES
    properties
        position
        velocity            = [0 0]
        acceleration        = [0 0]
        radius
        goal
        id
        deltaT
        maxSpeed            = 4
        measurementRadius   = 10
        distanceToReachGoal = 0.5 % it might be buggy, agent needs to be patient near the goal.
        speedProtectedRatio = 1
        protectedDist       = 0.1
        RVO_alpha           = 0.5
        dist_epsilon        = 0.1
        dist_signal         = 5
        
        % coefficiency for truncated VO; the larger the less truncated
        % space, tau must > 1
        tau                 = 2
        type                = 'agent'
        neighbour
    end
    
    %% CONSTRUTOR (IN LIST CONSTRUCTOR WAY)
    % construction function
    methods(Access=public)
        %%
        function obj = Agent(varargin)
            % used for instantiate the agent object
            obj.position    = varargin{1};
            obj.velocity    = varargin{2};
            obj.radius      = varargin{3};
            obj.id          = varargin{4};
            obj.deltaT      = varargin{5};
            fprintf("[INFO]\t GENERATING NO.%d AGENT\n", obj.id);
        end
    end
    
    %% API FUNCTIONS
    methods
        function obj = SetGoal(obj, goal)
            % for different phase purpose
            obj.goal = goal;
        end
        %%
        function [neighbour, s, minDist] = calNN(obj, config)
            % find neighbours for the agent
            minDist = intmax;
            s = 0;
            for i = 1:length(config.objType)
                objType = config.objType{i};
                buffer.(objType)  = [];
                if isfield(config, objType) == true
                    listObj = config.(objType);
                    for j = 1:length(listObj)
                        dist = norm(obj.position - listObj(j).position);
                        if dist < minDist && dist ~= 0
                            minDist = dist;
                        end
                        if dist > obj.measurementRadius || dist == 0
                            continue
                        end
                        buffer.(objType) = [buffer.(objType) listObj(j)];
                    end
                end
                neighbour.(objType) = buffer.(objType);
            end
        end
        
%         TODO using kd-tree to search neighbours
%         function [neighbour, s, minDist] = calNeighbourUsingKdtree(obj, config)
%             
%         end
        
        %% calculate Velocity Obstacle 
        function allVO = calVO(obj, nn_agent, patMethod, nn_obstacle, obsMethod, nnpoly, polyMethod)
            % get all velocity obstacles
            % calculate velocity obstacle for every agent
            % we did not use nargin method to deal with default inputs 

            allVO = [];
            
            if ~isempty(nn_agent)
                for i = 1:size(nn_agent,2) 
                    allVO = [allVO obj.helperCalVelocityObstacle(nn_agent(i), patMethod)];
                end
            end
            if ~isempty(nn_obstacle)
                for i = 1:size(nn_obstacle,2) 
                    allVO = [allVO obj.helperCalVelocityObstacle(nn_obstacle(i), obsMethod)];
                end
            end
            if ~isempty(nnpoly)
                for i = 1:size(nnpoly,2) 
                    allVO = [allVO obj.helperCalVelocityObstacle(nnpoly(i), polyMethod)];
                end
            end
        end
        
        %%
        function flag = isReachGoal(obj)
%             persistent print
%             print = false;
            if sum((obj.position - obj.goal).^2) < obj.distanceToReachGoal^2
                flag = true;
%                 if ~print, fprintf("[INFO]\t AGENT %d REACHED GOAL\n", obj.id); end
%                 print = true;
            else
                flag = false;    
            end
        end
        
        %%
        function obj = update(obj, optVelocity)
            % update States for agent
            % position, acceleration, velocity in deltaT
            
            obj.position = obj.position + optVelocity*obj.deltaT;
            obj.acceleration = optVelocity - obj.velocity;
            obj.velocity = optVelocity;
        end
        
        %% get optimal velocity for the agent
        function [optimalVelocity, prefVelocity]= calOptVel(obj, vo, CONFIG, phase)

%             if ~isempty(neighbours.agents)
%                 for i = 1:size(neighbours.agents, 2) 
%                     vo_tmp = obj.helperCalVelocityObstacle(neighbours.agents(i), voMethods(1));
%                     if ~isreal(vo_tmp)
%                         optimalVelocity = obj.helperCalCollisionVelocity(neighbours.agents(i));
%                         return
%                     end
%                 end
%             end
%             if ~isempty(neighbours.circleBlock)
%                 for i = 1:size(neighbours.circleBlock, 2) 
%                     allVO = [allVO obj.helperCalVelocityObstacle(neighbours.circleBlock(i), voMethods(2))];
%                     if ~isreal(vo_tmp)
%                         optimalVelocity = obj.helperCalCollisionVelocity(neighbours.agents(i));
%                         return
%                     end
% 
%                 end
%             end
%             if ~isempty(neighbours.polygonBlock)
%                 for i = 1:size(neighbours.polygonBlock, 2) 
%                     allVO = [allVO obj.helperCalVelocityObstacle(neighbours.polygonBlock(i), voMethods(2))];
%                     if ~isreal(vo_tmp)
%                         optimalVelocity = obj.helperCalCollisionVelocity(neighbours.agents(i));
%                         return
%                     end
% 
%                 end
%             end
            
            % some visualization requirements
            global SHOW_SINGLE_AGENT_VO 
            global SHOW_SINGLE_AGENT_VP 
            global SHOW_ALL_AGENT_VELOCITY 
            global PlotWhileSim 
            global SELECTED_IDX
            
            optimalVelocity = zeros(1,2);
           
            % -----------------------------
            % need to be dynamic, TODO 
            % -----------------------------
            
            if ~isreal(vo)
                % 
                % vo has image part
                %
                optimalVelocity = obj.helperCalCollisionVelocity();
            else
                % velocity magnitude filter
                vel_epsilon_filter = 0.1;

                % calculate preferred velocity
                prefVelocity = obj.helperCalPrefVelocity(CONFIG, phase);

                % extract reachable velocity
                velocityMap = obj.helperCalVelocityMap();
                voCount = size(vo,2)/2;

                % using build-in polyshape() to do geometry calculation
                velocityMapPgon = polyshape(velocityMap);

                % construct polyshape for each VO
                for i = 1:voCount
                    vo_idx = 2*(i-1) + 1;

                    voPgon = polyshape(vo(:, vo_idx:vo_idx+1));

                    velocityMapPgon = subtract(velocityMapPgon, voPgon);

                    if SHOW_SINGLE_AGENT_VO == true && obj.id == SELECTED_IDX && PlotWhileSim == true
                        voPgon4show = polyshape(obj.position + vo(:, vo_idx:vo_idx+1));
                        plot(voPgon4show,...
                            'FaceColor', 'blue',...
                            'FaceAlpha', 0.1,...
                            'EdgeColor', 'none');
                    end
                end

                % select reachable velocity
                reachableVelocityCandidates = velocityMapPgon.Vertices;

                % plot reachable velocity map for visualizations
                if SHOW_SINGLE_AGENT_VP == true && obj.id == SELECTED_IDX && PlotWhileSim == true
                    plot(polyshape(reachableVelocityCandidates + obj.position), ...
                            'FaceColor', 'c',...
                            'FaceAlpha', 0.4,...
                            'EdgeColor', 'none'); 
                end

                % argmin |Vi - Vpref|_2
                n_reachableVelocity = size(reachableVelocityCandidates, 1);
                dist_min = intmax;
                if n_reachableVelocity ~= 0
                    for i = 1:n_reachableVelocity
                       candidate = reachableVelocityCandidates(i,:);
                       if norm(candidate) < vel_epsilon_filter*obj.maxSpeed
                           continue
                       end
                       if norm(candidate-prefVelocity) < dist_min
                           dist_min = norm(candidate-prefVelocity);
                           optimalVelocity = candidate;
                       end
                    end
                end
                % add perturbation to break symmetry
                angle = rand*2.0*pi; 
                dist =  rand*0.05;
                optimalVelocity = optimalVelocity + dist*[cos(angle), sin(angle)];
                % plot while simulation
                if SHOW_ALL_AGENT_VELOCITY == true && PlotWhileSim == true
                    nxtpos = obj.position + optimalVelocity;
                    plot([nxtpos(1), obj.position(1)], [nxtpos(2), obj.position(2)], 'b-');
                end
            end
        end
        

    end
    
    %% PRIVATE METHODS
    methods(Access = private)
%   >>>>>>>>>>>>>>>>>>>   PRIVATE HELPER FUNCTIONS   <<<<<<<<<<<<<<<<<<<<<
    %% prefVel
    function prefVelocity = helperCalPrefVelocity(obj, CONFIG, phase)
        %helperCalPrefVelocity - calculate preferrenced velocity in
        %goal-oriented
        % &
        %consensus-based formation in 3 types
        %  position-based, 
        %  displacement-based, 
        %  distance-based
        target_part = obj.goal - obj.position;
        target_part = target_part/norm(target_part);
        ft = CONFIG.formation_type;
        switch ft
        case 'none' % goal oriented
            prefVelocity = obj.maxSpeed*target_part;
%             fprintf("%d agent prefV = (%f, %f)\n",obj.id, prefVelocity(1), prefVelocity(2));
            return;

        case 'position'
            disp('no implemented')
            return;

        case 'displacement'
            coff_pos = 8.5;
            coff_vel = 2;
            
            adjacant            = CONFIG.adjacantMatrix;
            opt_displacement    = CONFIG.displacementMatrix(:,:,phase);
            
            objID = obj.id;
            num_adj = 0; % #neighbour
            nn_idx = [];
            
            for i = 1:length(adjacant(objID,:))
                if adjacant(objID,i) ~= 0
                    num_adj = num_adj + 1;
                    nn_idx(end+1) = i;
                end
            end

            consensus_part = zeros(1,2);

            for i = 1:num_adj
                opt_d = opt_displacement(objID, 2*i-1:2*i);
                cur_d = CONFIG.agents(nn_idx(i)).position - obj.position;
                consensus_part = consensus_part +...
                    coff_pos*(cur_d - opt_d) +...
                    coff_vel*(obj.velocity - CONFIG.agents(nn_idx(i)).velocity);
            end

            consensus_part = consensus_part/norm(consensus_part);
            
            prefVelocity = obj.maxSpeed*(CONFIG.gamma*consensus_part + (1-CONFIG.gamma)*target_part);
            
            return;

        case 'distance'
            disp('Not Implemented.')
            return;
        end
    end	
    
    end
    
    methods(Access=private)
    
    %% collision cone vertex calculation
    function [ccLeftUpperBoundVertice,...
                ccRightUpperBoundVertice,...
                ccRightLowerBoundVertice,...
                ccLeftLowerBoundVertice] = helperCalCollisionCone(obj, that, sigmaLength, leftSigma, rightSigma, alpha, tau)
        if nargin == 7
            tau_prime = tau;
        else
            tau_prime = obj.tau;
        end
        tauLength =  ((norm(obj.position - that.position) - obj.radius - that.radius)*cos(alpha))/tau_prime;
        ccLeftUpperBoundVertice  = [sigmaLength*cos(leftSigma),  sigmaLength*sin(leftSigma)];
        ccRightUpperBoundVertice = [sigmaLength*cos(rightSigma), sigmaLength*sin(rightSigma)];
        ccLeftLowerBoundVertice  = [tauLength*cos(leftSigma),    tauLength*sin(leftSigma)];
        ccRightLowerBoundVertice = [tauLength*cos(rightSigma),   tauLength*sin(rightSigma)];
    end
    
    %% velMap
    function velocityMap = helperCalVelocityMap(obj)
        %helperCalVelocityMap - Double Integrator Velocity Map
        % velocityMap = helperCalVelocityMap()
        % with or without acceleration constraint
        
        % with acc
%         i = 0:0.01:2*pi;
%         rvx = obj.velocity(1) + obj.speedProtectedRatio*obj.acc_abs*cos(i);
%         rvy = obj.velocity(2) + obj.speedProtectedRatio*obj.acc_abs*sin(i);
%         candidateVel = polyshape([rvx', rvy']);
%         vx = obj.maxSpeed*cos(i);
%         vy = obj.maxSpeed*sin(i);
%         maxVel = polyshape([vx', vy']);
%         reachableVel = intersect(candidateVel, maxVel);
        
        % without acc
        i = 0:0.01:2*pi;
        vx = obj.maxSpeed*cos(i);
        vy = obj.maxSpeed*sin(i);
        reachableVel = polyshape([vx', vy']);
        
        velocityMap = reachableVel.Vertices;
    end
    
    %% vo calculation
    function velocityObstacle = helperCalVelocityObstacle(obj, that, method)
    %helperCalVelocityObstacle - calculate VO and RVO for agent
    % velocityObstacle = helperCalVelocityObstacle(neighbour, 'VO' or 'RVO')

        if strcmp(that.type, "polygon") == 1
            % treat polygon as circles temporarily
            velocityObstacle = obj.helperCalPolygonAsCircleVelocityObstacle(that, method);
        else
            % circle obstacle recipe
            coneAlpha = 1;
            % to avoid collision, add safe distance between two agents
            threshold = obj.radius + that.radius;
            radiusHat = that.radius + obj.radius;
            posRelativeVector = that.position - obj.position;
            
            posRelativeDistance = norm(posRelativeVector);
%             posRelativeDistance = norm(posRelativeVector) - obj.dist_epsilon;
            
            if posRelativeDistance <= threshold
                % collision happens
                % no need to calculate VO, pop out
                
            end

            % theta ~ [-pi, pi]
            theta = atan2(posRelativeVector(2), posRelativeVector(1));
            % alpha ~ (0, pi/2)
            alpha = asin(radiusHat/posRelativeDistance);
            % sigma boundary
            leftSigma = theta+alpha;
            rightSigma = theta-alpha;
            
            % calculation, may convert to switch-case style
            if strcmp(method, 'VO') == 1
                % velocity obstacle cone length calculation
                sigmaLength = coneAlpha*(obj.maxSpeed + norm(that.velocity)) / cos(alpha);
                % collision cone boundary (left/right sigma)
                ccLeftBoundVertice = [sigmaLength*cos(leftSigma), sigmaLength*sin(leftSigma)];
                ccRightBoundVertice = [sigmaLength*cos(rightSigma), sigmaLength*sin(rightSigma)];
                ccApex = [0,0];
                % offset transition vector
                transitionVector = that.velocity;
                % vo cone calculation
                velocityObstacle = [ccLeftBoundVertice + transitionVector;...
                    ccRightBoundVertice + transitionVector;...
                    ccApex + transitionVector];
            elseif strcmp(method, 'RVO') == 1
                % velocity obstacle cone length calculation
                sigmaLength = coneAlpha*(obj.maxSpeed + norm(that.velocity + obj.velocity)) / cos(alpha);
                % collision cone boundary (left/right sigma)
                ccLeftBoundVertice = [sigmaLength*cos(leftSigma), sigmaLength*sin(leftSigma)];
                ccRightBoundVertice = [sigmaLength*cos(rightSigma), sigmaLength*sin(rightSigma)];
                ccApex = [0,0]; 
                % RVO_alpha ~ [0,1] defines the behavior of agent
                % the larger, the more aggressive the agent will be.
                % the smaller, the more softer the agent will be.
                transitionVector = obj.RVO_alpha*(obj.velocity + that.velocity);
                velocityObstacle = [ccLeftBoundVertice + transitionVector;...
                    ccRightBoundVertice + transitionVector;...
                    ccApex + transitionVector];
            elseif strcmp(method, 'VOT') == 1
                % velocity obstacle cone length calculation
                sigmaLength = coneAlpha*(obj.maxSpeed + norm(that.velocity)) / cos(alpha);
                % truncated velocity obstacle
                [ccLeftUpperBoundVertice, ccRightUpperBoundVertice,...
                    ccRightLowerBoundVertice, ccLeftLowerBoundVertice] = obj.helperCalCollisionCone(that, sigmaLength, leftSigma, rightSigma, alpha);
                transitionVector = that.velocity;
                velocityObstacle = [ccLeftUpperBoundVertice + transitionVector;...
                    ccRightUpperBoundVertice + transitionVector;...
                    ccRightLowerBoundVertice + transitionVector;...
                    ccLeftLowerBoundVertice + transitionVector];
            elseif strcmp(method, 'RVOT') == 1
                % velocity obstacle cone length calculation
                sigmaLength = coneAlpha*(obj.maxSpeed + norm(that.velocity + obj.velocity)) / cos(alpha);
                % truncated reciprocal velocity obstacle
                [ccLeftUpperBoundVertice, ccRightUpperBoundVertice,...
                    ccRightLowerBoundVertice, ccLeftLowerBoundVertice] = obj.helperCalCollisionCone(that, sigmaLength, leftSigma, rightSigma, alpha, 10);
                transitionVector = obj.RVO_alpha*(obj.velocity + that.velocity);
                velocityObstacle = [ccLeftUpperBoundVertice + transitionVector;...
                    ccRightUpperBoundVertice + transitionVector;...
                    ccRightLowerBoundVertice + transitionVector;...
                    ccLeftLowerBoundVertice + transitionVector];
            else
                error('VO variant not supported.')
            end
        end
    end 
    %%
    
    function collisionVelocity = helperCalCollisionVelocity(obj)
%         repulsiveVector = obj.position-that.position;
%         repulsiveTheta  = atan2(repulsiveVector(2), repulsiveVector(1));
%         collisionVelocity = obj.maxSpeed*[cos(repulsiveTheta) sin(repulsiveTheta)];
        collisionVelocity = -1.2*obj.velocity;
    end
    
    %%
    function vo = helperCalPolygonAsCircleVelocityObstacle(obj, that, method)
        %helperCalPolygonAsCircleVelocityObstacle
        that.radius = sqrt(that.width^2+that.height^2);
        that.type = 'circle';
        vo = obj.helperCalVelocityObstacle(that, method);
    end

    end
    
    
    %% PLOTTING METHODS   
    % plotting functions
    methods
        % it should be later extended to much more compatible way.
        % add ax variable to be specific in plotting
        %% display function
        function [x, y] = show(obj)
            x = obj.position(1) + obj.radius * cos(0:0.01:2*pi);
            y = obj.position(2) + obj.radius * sin(0:0.01:2*pi);

            plot(polyshape([x', y']),...
                'FaceColor', '#230A59',...
                'FaceAlpha', 0.7,...
                'LineStyle', 'none');
            
            
            plot([obj.position(1) obj.goal(1)], [obj.position(2) obj.goal(2)], ...
                'LineStyle', '--',...
                'Marker', '+',...
                'Color', 'red');
            
%             text(obj.position(1),...
%                 obj.position(2),...
%                 num2str(obj.id), ...
%                 'FontSize', 15,...
%                 'FontSmoothing', 'on',...
%                 'HorizontalAlignment', 'center');
        end
    end
    
end