function deadlockVelocity = helperCalDeadlockVelocity(obj)
            % deal with the deadlock senario
            rvalue = 0.9 + 0.2*rand('double');
            deadlockVelocity = -rvalue*obj.velocity;
%             deadlockVelocity = [0.0];
        end