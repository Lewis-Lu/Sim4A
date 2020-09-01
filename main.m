% ------------------
% Formation Simulation
% Author: Lu, hong
% luhong[AT]westlake.edu.cn
% luh.lewis[AT]gmail.com
% VERSION:1.4.1
% Date: 2020.5.27
% ------------------

%%
clc; close all;

% add sim pathes
addpath('util'); addpath('im'); addpath('video');

% add profile moniter
% profile on; profile viewer;

%% initialization

% global params
global SHOW_SINGLE_AGENT_VO 
global SHOW_SINGLE_AGENT_VP 
global SHOW_ALL_AGENT_VELOCITY 
global SHOW_TRAJECTORY
global PlotWhileSim
global SELECTED_IDX
global SHOW_CONNECTIVITY 
global PAUSE


% -----------parameters needs to be set------------

PAUSE                   = false;    % pause within every sim step
SHOW_CONNECTIVITY       = false;     % show adjacant matrix
SHOW_TRAJECTORY         = false;    % show trajectory
SHOW_SINGLE_AGENT_VO    = true;     % show specified agent's VOs
SHOW_SINGLE_AGENT_VP    = true;    % show specified agent's Velocity Map
SHOW_ALL_AGENT_VELOCITY = false;    % show all agents' velocities
PlotWhileSim            = true;     % plot while sim's processing, default = TRUE
SELECTED_IDX            = 16;        % specified index of agent

% identify the environment name in the [MAP] folder
envName = 'giveTheWay';

% --------------------------------------------------

%% DO NOT MODIFIED CODES IN THE FOLLOWING PARTS ...

% initialize CONFIGURATION
CONFIG = envInit(envName);

% cleaning img cache
system("rm -rf im/*");

%% sim loop

fprintf('\n[SIM]\t NEW SIM BEGINS \n');

if PlotWhileSim == true
    f1 = figure();
end

for p = 1:CONFIG.phase
    fprintf('[SIM]\t NEW PHASE BEGINS \n');
    
    % In phase p, the formation or arbitrary position assignment
    CONFIG.simEndFlag = false;
  
    % goal assginment in phase NO. phaseNumber
    switch CONFIG.formation_type
        case 'none'
            % do nothing, goal has been assigned in the envInit script.
        case 'displacement'
            for i = 1:CONFIG.num_agent
                if i == CONFIG.leader_id
                    CONFIG.agents(CONFIG.leader_id) = CONFIG.agents(CONFIG.leader_id).SetGoal(CONFIG.leader_goals(p,:));
                    fprintf("[SIM]\t IN PHASE %d, Leader's goal: (%f, %f)\n", p, CONFIG.agents(1).goal(1), CONFIG.agents(1).goal(2));
                else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TODO displacement matrix here to be fixed
                    %
                    %
                    %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    CONFIG.agents(i) = CONFIG.agents(i).SetGoal(CONFIG.leader_goals(p,:) + CONFIG.displacementMatrix(CONFIG.leader_id,2*i-3:2*i-2,p));
                    fprintf("[SIM]\t IN PHASE %d, AGENT %d goal: (%f, %f)\n", p, i, CONFIG.agents(i).goal(1), CONFIG.agents(i).goal(2));
                end
            end
    end
    
    while ~CONFIG.simEndFlag
        if PlotWhileSim == true
            pause(CONFIG.deltaT);
            f1 = clf(f1);
            hold on; 
            axis equal; 
            axis(CONFIG.boundary);
            xlabel('x(m)');
            ylabel('y(m)');
            title({'Simulation'; ['simTime(s) ' num2str(CONFIG.simTime)]})
        end

        % inverse the flag first.
        CONFIG.simEndFlag = true;
        
            CONFIG.X = double.empty(0,2);
            for i = 1:length(CONFIG.objType)
                if isfield(CONFIG, CONFIG.objType{i})
                    for j = 1:length(CONFIG.(CONFIG.objType{i}))
                        tmp = CONFIG.(CONFIG.objType{i})(j).position;
                        CONFIG.X(end+1,:) = tmp;
                    end
                end
            end
        
        % document states
        for i = 1:length(CONFIG.objType)
            type = CONFIG.objType{i};
            if isfield(CONFIG, type) == true
                listObj = CONFIG.(type);
                for j = 1:length(listObj)
                    listObj(j).show();
                    CONFIG.buffer.(type)(2*j-1:2*j) = listObj(j).position;
                end
                CONFIG.trajectory.(type) = [CONFIG.trajectory.(type); CONFIG.buffer.(type)];
                if SHOW_TRAJECTORY == true
                    for j = 1:length(listObj)
                        plot(CONFIG.trajectory.agents(:,2*j-1), CONFIG.trajectory.agents(:,2*j), 'o-');
                    end
                end
            end
        end
        
        
        
        if strcmp(CONFIG.formation_type, 'displacement') && SHOW_CONNECTIVITY
            for i = 1:size(CONFIG.adjacantMatrix, 1)
                for j = 1:size(CONFIG.adjacantMatrix, 2)
                   if CONFIG.adjacantMatrix(i, j) ~= 0
                       plot([CONFIG.agents(i).position(1), CONFIG.agents(j).position(1)],...
                           [CONFIG.agents(i).position(2), CONFIG.agents(j).position(2)], 'k-');
                   end
                end
            end
        end

        for i = 1:CONFIG.num_agent
            [nn, s, minDist] = CONFIG.agents(i).calNN(CONFIG);
            CONFIG.buffer.nDist(i) = minDist;
            CONFIG.cwdSignal = s;
            if strcmp(CONFIG.voMethod, 'Origin') == 1 || strcmp(CONFIG.voMethod, 'origin') == 1
                velocity_obstacle = CONFIG.agents(i).calVO(nn.agents, 'RVO', nn.circleBlock, 'VO', nn.polygonBlock, 'VO');
            elseif strcmp(CONFIG.voMethod, 'Truncated') == 1 || strcmp(CONFIG.voMethod, 'truncated') == 1
                velocity_obstacle = CONFIG.agents(i).calVO(nn.agents, 'RVOT', nn.circleBlock, 'VOT', nn.polygonBlock, 'VOT');
            end
            CONFIG.optVel(2*i-1:2*i) = CONFIG.agents(i).calOptVel(velocity_obstacle, CONFIG, p);
            
%             rrtSearcher = RRT(CONFIG.agents(1), CONFIG, nn);
%             tnode = rrtSearcher.search();
%             rrtSearcher.show();
             
        end
        
        % document interagent nearest distance
        CONFIG.nearestDist  = [CONFIG.nearestDist; CONFIG.buffer.nDist];
        CONFIG.timeSeries   = [CONFIG.timeSeries CONFIG.simTime];

        for i = 1:length(CONFIG.objType)
            type = CONFIG.objType{i};
            if isfield(CONFIG, type) == true
                switch type
                    case 'agents'
                        for j = 1:length(CONFIG.(type))
                            CONFIG.(type)(j) = CONFIG.(type)(j).update(CONFIG.optVel(2*j-1:2*j));
                            CONFIG.simEndFlag = CONFIG.simEndFlag & CONFIG.(type)(j).isReachGoal();
                        end
                    case 'circleBlock'
                        for j = 1:length(CONFIG.(type))
                            CONFIG.(type)(j) = CONFIG.(type)(j).update();
                        end
                    case 'polygonBlock'
                        for j = 1:length(CONFIG.(type))
                            CONFIG.(type)(j) = CONFIG.(type)(j).update();
                        end
                end
            end
        end
        
        
        % capture and output stream
        filename = ['im\' num2str(CONFIG.frame) '.jpg'];
        saveas(gcf, filename);
        
        CONFIG.simTime  = CONFIG.simTime + CONFIG.deltaT;
        CONFIG.frame    = CONFIG.frame + 1;

        if PAUSE
            fprintf("paused\n");
            pause
        end
    end
end

%% minimum inter-agent and inter-obstacle distance
f2 = figure();
axis equal;
hold on;
xlabel('time(s)');
ylabel('minimum interval distance(m)');
threshold = 2*CONFIG.agents(1).radius;
plot(CONFIG.timeSeries, CONFIG.nearestDist', '-.');
plot([CONFIG.timeSeries(1), CONFIG.timeSeries(end)], [threshold, threshold], 'k-', 'LineWidth', 2);
saveas(f2, ['result/' CONFIG.filename '.jpg']);

%% prompt in the command line to ask if animate
prompt = "animate this episode? (Y/N)";
s = input(prompt, 's');
if s == "Y" || s == "y" || isempty(s)
    animate(CONFIG);
end
