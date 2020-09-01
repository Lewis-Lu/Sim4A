function flag = isReachGoal(obj)
            if sum((obj.position - obj.goal).^2) < obj.distanceToReachGoal^2
                flag = true;
            else
                flag = false;    
            end
        end