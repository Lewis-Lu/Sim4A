%% path addition
addpath('util/');
addpath('remApi/');
addpath('CachedValues/');


%%
n_model     = 3;
trackWidth  = 0.5; % (m)
delay       = 4; % (cs)

carHandleSet = zeros(1, n_model);
leftMotorHandleSet = zeros(1, n_model);
rightMotorHandleSet = zeros(1, n_model);

carPositionSet = [11,11,0;
                5,-15,0;
                -20,0,0]';

velocitySet = calVelocity4Wheels(p_dot, w_dot, trackWidth);

modelPath = 'myRobot/Unicycle.ttm';

% construct Vrep object
vrep = Vrep();

for i = 1:n_model
    % get handles
    carHandleSet(i) = vrep.loadModel(modelPath);
    leftMotorHandleSet(i) = vrep.getLeftMotorHandle(carHandleSet(i));
    rightMotorHandleSet(i) = vrep.getRightMotorHandle(carHandleSet(i));
    % set positions
    vrep.setPosition(carHandleSet(i), carPositionSet(:,i)');
end

% push start button to simulate
vrep.sim.simxStartSimulation(vrep.clientID, vrep.sim.simx_opmode_oneshot);


for i = 1:2:size(velocitySet, 1)
    for j = 1:n_model
        vrep.setJointVelocity(leftMotorHandleSet(j), velocitySet(i, j));
        vrep.setJointVelocity(rightMotorHandleSet(j), velocitySet(i+1, j));
        pause(delay/100)
    end
end

for i = 1:n_model
    vrep.removeModel(carHandleSet(i));
end
vrep.sim.simxStopSimulation(vrep.clientID, vrep.sim.simx_opmode_oneshot_wait);
vrep.sim.simxFinish(vrep.clientID);
vrep.sim.delete();

% calVelocity4Wheels
% Decomposit the linear and angular velocity into wheel velocity
%
%


function velocitySet = calVelocity4Wheels(pDotSet, wDotSet, trackWidth)
    velocitySet = zeros(2*size(pDotSet,1), size(pDotSet,2));
    for i = 1:size(pDotSet, 1)
        for j = 1:size(pDotSet, 2)
            velocitySet(2*i-1, j)   = pDotSet(i,j) - wDotSet(i,j)*trackWidth/2; 
            velocitySet(2*i, j)     = pDotSet(i,j) + wDotSet(i,j)*trackWidth/2;
        end
    end
end

