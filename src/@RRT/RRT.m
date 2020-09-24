% ------------------
% class file for rrt
% Author: Lu, hong
% luhong@westlake.edu.cn
% VERSION:1.4.1
% Date: 2020.6.1
% ------------------

classdef RRT < handle
    %RRT - Rapid Random Exploring Tree Method
    %   
    
    %% Properties
    properties
        start
        goal
        edge
        vertices            % tree vertice buffer
        search_iter         = 1000  % max search iterations
        prob                = 0.5   % probabilty to search for space except alonging with the goal direction
        direction_visited   
        search_radius
        map
        step
        neighbour
    end
    
    %% CONSTRUCTOR
    methods
        function obj = RRT(that, config, neighbour)
            % @that: the agent object
            % @arg: initialization arguments
            obj.start = that.position;
            obj.goal  = that.goal;
            obj.step = that.maxSpeed/15;
            obj.vertices = [that.position];
            obj.edge = containers.Map({'1'}, {[]});
            obj.search_radius = that.measurementRadius/2;
            obj.neighbour = neighbour;
            % arg parser
            obj.direction_visited = zeros(4,1);
            obj.map = config;
        end
    end
    
    %% Tree building
    methods
        function targetNode = search(obj)
            for iter = 1:obj.search_iter
                rng('shuffle');
                p = rand();
                if p > obj.prob
                    q_rand = obj.goal;
                else
                    width = obj.map.boundary(2) - obj.map.boundary(1);
                    height = obj.map.boundary(4) - obj.map.boundary(3);
                    q_rand = [width*rand()+obj.map.boundary(1) ...
                        height*rand()+obj.map.boundary(3)];
                end
                % generate a node along the q_start -> q_rand direction
                [s_add, finished, node] = obj.helperAddNewNode(q_rand);
                
                if s_add == false
                    continue
                end
                if finished == true
                   targetNode = node; 
                   break
                end
            end
        end
    end
    
    %% SHOW 
    
    methods 
        function show(obj)
            for i = 1:obj.edge.Count
                children = obj.edge(num2str(i));
                nChild = size(children, 2);
                
                if nChild == 0
                   continue 
                end
                
                vs = obj.vertices(i,:);
                for j = 1:nChild  
                    vc = obj.vertices(children(j),:);
                    plot([vs(1) vc(1)], [vs(2) vc(2)], '-o', 'Color' ,'#440066');
                end
            end
        end
    end
    
end

