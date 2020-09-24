function agents = randomInitAgent(r, N, deltaT)
    % randomly init agents in the counterclockwise order in a circle
    agents      = Agent.empty(N,0);
    interval    = (2*pi)/N;
    
    for i = 1:N
        position    = r*[cos(interval*(i-1)) sin(interval*(i-1))];
        radius      = 1;
        goal        = -position;
        agents(end+1) = Agent("randomGen", position, radius, goal, i, deltaT);
    end
end