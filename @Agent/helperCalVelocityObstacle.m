 function velocityObstacle = helperCalVelocityObstacle(obj, that, method)
            %helperCalVelocityObstacle - calculate VO and RVO for agent
            % velocityObstacle = helperCalVelocityObstacle(neighbour, 'VO' or 'RVO')
            
            if strcmp(that.type, "polygon") == 1
                % treat polygon as circles temporarily
                velocityObstacle = obj.helperCalPolygonAsCircleVelocityObstacle(that, method);
            else
                coneAlpha = 1;
                % To avoid collision, add safe Distance between two agents
                radiusHat = that.radius + obj.radius + obj.protectZone;
                posRelativeVector = that.position - obj.position;
                posDist = norm(posRelativeVector) - obj.dist_epsilon;
                % theta ~ [-pi, pi]
                theta = atan2(posRelativeVector(2), posRelativeVector(1));
                % alpha ~ (0, pi/2)
                alpha = asin(radiusHat/posDist);
                % sigma boundary
                leftSigma = theta+alpha;  
                rightSigma = theta-alpha;
                % calculation
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
                    velocityObstacle = [ccLeftBoundVertice + transitionVector; ccRightBoundVertice + transitionVector; ccApex + transitionVector];
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
                    velocityObstacle = [ccLeftBoundVertice + transitionVector; ccRightBoundVertice + transitionVector; ccApex + transitionVector];
                elseif strcmp(method, 'VOT') == 1
                    % velocity obstacle cone length calculation
                    sigmaLength = coneAlpha*(obj.maxSpeed + norm(that.velocity)) / cos(alpha);
                    % truncated velocity obstacle
                    [ccLeftUpperBoundVertice, ccRightUpperBoundVertice, ccRightLowerBoundVertice, ccLeftLowerBoundVertice] = obj.helperCalCollisionCone(that, sigmaLength, leftSigma, rightSigma, alpha);
                    transitionVector = that.velocity;
                    velocityObstacle = [ccLeftUpperBoundVertice + transitionVector; ccRightUpperBoundVertice + transitionVector; ccRightLowerBoundVertice + transitionVector; ccLeftLowerBoundVertice + transitionVector];
                    
                elseif strcmp(method, 'RVOT') == 1
                    % velocity obstacle cone length calculation
                    sigmaLength = coneAlpha*(obj.maxSpeed + norm(that.velocity + obj.velocity)) / cos(alpha);
                    % truncated reciprocal velocity obstacle
                    [ccLeftUpperBoundVertice, ccRightUpperBoundVertice, ccRightLowerBoundVertice, ccLeftLowerBoundVertice] = obj.helperCalCollisionCone(that, sigmaLength, leftSigma, rightSigma, alpha, 10);
                    transitionVector = obj.RVO_alpha*(obj.velocity + that.velocity);
                    velocityObstacle = [ccLeftUpperBoundVertice + transitionVector; ccRightUpperBoundVertice + transitionVector; ccRightLowerBoundVertice + transitionVector; ccLeftLowerBoundVertice + transitionVector];
                else
                    error('VO variant not supported.')
                end
            end
        end 