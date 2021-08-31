function plotting(timestep, traj, obstacles, radius, filename, L)
    obsShape_ = polyshape();
    nObs = size(obstacles,2);
    for i = 1:nObs
        vertices = obstacles(:,i);
        vReshape = reshape(vertices, [size(vertices,1)/4, 4]);
        obsTmp = polyshape([[vReshape(1,1), vReshape(2,1)];[vReshape(1,2), vReshape(2,2)]; ...
            [vReshape(1,3), vReshape(2,3)];[vReshape(1,4), vReshape(2,4)]]);
        obsShape_ = union(obsShape_, obsTmp);
    end

    nIter = size(timestep, 2);

    fig = figure;
    
    for i = 1:nIter
        agentTraj = traj(:,i); 

        fig = clf(fig);
        axis equal; hold on; axis([-1.5*L 1.5*L -L L]);
        title({['Time = ' num2str(timestep(size(timestep,2))) 's'], [num2str(timestep(i)) 's']})

        plot(obsShape_);
        for j = 1:2:size(agentTraj,1)
           posx = agentTraj(j);
           posy = agentTraj(j+1);
           r = 0:0.01:2*pi;
           plot(posx + radius*cos(r), posy + radius*sin(r), 'r-');
        end

        frame = getframe(fig);
        im = frame2im(frame);
        [imind, cm] = rgb2ind(im, 1024);
        if i == 1
           imwrite(imind, cm, filename, 'DelayTime', 0.1, 'Loopcount',inf);
        else
           imwrite(imind, cm, filename, 'DelayTime', 0.1, 'WriteMode','append');
        end    
    end
end