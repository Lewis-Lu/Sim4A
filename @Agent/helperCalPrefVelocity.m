%helperCalPrefVelocity - calculate preferrenced velocity in
%goal-oriented
% &
%consensus-based formation in 3 types
%  position-based, displacement-based, distance-based

%  Velocity = helperCalDesiredVelocity(list, A, idx, gamma, u, cwdSignal, varargin)

function prefVelocity = helperCalPrefVelocity(obj, CONFIG, phase)
    
    target_part = obj.goal - obj.position;
    target_part = target_part/norm(target_part);
    
    type = CONFIG.formation_type;
        
    switch type
    case 'none' % goal oriented
        prefVelocity = obj.maxSpeed*target_part;
        return;

    case 'position'
        disp('no implemented')
        return;

    case 'displacement'
        adjacant = CONFIG.adjacantMatrix;
        id = obj.id;
        n_n = 0; % #neighbour
        nn_idx = [];
        opt_displacement = CONFIG.opt_displacement(:,:,phase);
        
        for i = 1:length(adjacant(id,:))
            if adjacant(id,i) ~= 0
                n_n = n_n + 1;
                nn_idx(end+1) = i;
            end
        end
        
        consensus_part = zeros(1,2);
        
        for i = 1:n_n
            opt_d = opt_displacement(id, 2*i-1:2*i);
            cur_d = CONFIG.agents(nn_idx(i)).position - obj.position;
            consensus_part = consensus_part + cur_d - opt_d;
            CONFIG.agents(id).goal = CONFIG.agents(nn_idx(i)).position - opt_d;
        end
        
        consensus_part = consensus_part/norm(consensus_part);
        prefVelocity = obj.maxSpeed*consensus_part;
        
        % leader index defaultly as 1
        if id == 1
            target_part = CONFIG.goals(2*phase-1: 2*phase)-obj.position;
            target_part = target_part/norm(target_part);
            prefVelocity = obj.maxSpeed*(CONFIG.gamma*consensus_part + (1-CONFIG.gamma)*target_part);
            CONFIG.agents(id).goal = CONFIG.goals(2*phase-1:2*phase);
        end
        return;

    case 'distance'
        disp('Not Implemented.')
        return;
    end
end