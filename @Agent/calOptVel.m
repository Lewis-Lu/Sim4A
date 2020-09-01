% calculate optimal velocity in velocity domain

function optimalVelocity = calOptVel(obj, vo, CONFIG, phase)
    % global variables statement
    global SHOW_SINGLE_AGENT_VO SHOW_SINGLE_AGENT_VP SHOW_ALL_AGENT_VELOCITY PlotWhileSim SELECTED_IDX
    optimalVelocity = zeros(1,2);
    if obj.isReachGoal()
        if obj.id == 1
            optimalVelocity = [0,0];
        end
        % -----------------------------
        % need to be dynamic, TODO 
        % -----------------------------
    elseif ~isreal(vo)
        optimalVelocity = obj.helperCalDeadlockVelocity();
    else
        velocity_filter_epsilon = 0.1;
        prefVelocity = obj.helperCalPrefVelocity(CONFIG, phase);
        velocityMap = obj.helperCalVelocityMap();
        voCount = size(vo,2)/2;
        % using polyshape() to do geometry calculation
        velocityMapPgon = polyshape(velocityMap);
        for i = 1:voCount
            vo_idx = 2*(i-1) + 1;
            voPgon = polyshape(vo(:, vo_idx:vo_idx+1));
            velocityMapPgon = subtract(velocityMapPgon, voPgon);

if SHOW_SINGLE_AGENT_VO == true && obj.id == SELECTED_IDX && PlotWhileSim == true
voPgon4show = polyshape(obj.position + vo(:, vo_idx:vo_idx+1));
plot(voPgon4show, 'FaceColor', 'blue', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
end
        end

        % select reachable velocity
        reachableVelocityMap = velocityMapPgon.Vertices;

% plot reachable velocity map for visualizations
if SHOW_SINGLE_AGENT_VP == true && obj.id == SELECTED_IDX && PlotWhileSim == true
plot(polyshape(reachableVelocityMap + obj.position), ...
    'FaceColor', 'blue', 'FaceAlpha', 0.1); 
end

        % argmin |Vi - Vpref|_2
        n_reachableVelocity = size(reachableVelocityMap, 1);
        dist_min = intmax;
        if n_reachableVelocity ~= 0
            for i = 1:n_reachableVelocity
               candidate = reachableVelocityMap(i,:);
               if norm(candidate) < velocity_filter_epsilon*obj.maxSpeed
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