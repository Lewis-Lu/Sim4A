function vo = helperCalPolygonVelocityObstacle(obj, that)
            %helperCalPolygonVelocityObstacle
            theta = zeros(4,1);
            distance = zeros(4,1);
            for i = 1:4
                line = that.Vertices(i,:) - obj.position;
                distance(i) = norm(line);
                theta(i) = atan2(line(2), line(1));
            end
            
            idx_right = theta == min(theta);
            idx_left = theta == max(theta);
            
            dist_right = min(distance(idx_right));
            dist_left = min(distance(idx_left));
            
            % offset angles to each side
            alphal = asin(obj.radius/dist_left);
            alphar = asin(obj.radius/dist_right);
            
            leftSigma = max(theta) + alphal;
            rightSigma = min(theta) - alphar;
            
            beta = leftSigma - rightSigma;
            
            sigmaLength = obj.maxSpeed / cos(beta/2);
            
            ccLeftBoundVertice = [sigmaLength*cos(leftSigma), sigmaLength*sin(leftSigma)];
            ccRightBoundVertice = [sigmaLength*cos(rightSigma), sigmaLength*sin(rightSigma)];
            ccApex = [0,0];
            vo = [ccLeftBoundVertice; ccRightBoundVertice; ccApex];
        end