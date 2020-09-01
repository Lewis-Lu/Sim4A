function velocityMap = helperCalVelocityMap(obj)
            %helperCalVelocityMap - Double Integrator Velocity Map
            % velocityMap = helperCalVelocityMap()
            % with acceleration constraint
            
            i = 0:0.01:2*pi;
            rvx = obj.velocity(1) + obj.speedProtectedRatio*obj.acc_abs*cos(i);
            rvy = obj.velocity(2) + obj.speedProtectedRatio*obj.acc_abs*sin(i);
            candidateVel = polyshape([rvx', rvy']);
            
            vx = obj.maxSpeed*cos(i);
            vy = obj.maxSpeed*sin(i);
            maxVel = polyshape([vx', vy']);
            
            reachableVel = intersect(candidateVel, maxVel);
            velocityMap = reachableVel.Vertices;
        end