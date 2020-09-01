function [particles, obstacles] = initVariable(map)
    particles = [];
    obstacles = [];
    
    deltaT = 0.1;
    
    particle = map.agent; 
    particleN = size(particle, 1);
    obstacle = map.circleBlock;
    obstacleN = size(obstacle, 1);

    if particleN
        particles = Particle(particleN, particle(:,1:2), particle(:,3:4), ...
            particle(:,5), particle(:,6:7), deltaT);
    end
    if obstacleN
        obstacles = Obstacle(obstacleN, obstacle(:,1:2), obstacle(:,3:4), ...
            obstacle(:,5), deltaT);
    end
end