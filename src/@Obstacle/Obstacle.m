% class definition file for 'Obstacle'
% 
% Written by Lu, Hong
% luhong@westlake.edu.cn

classdef Obstacle
    % Obstacle
    properties
        position
        velocity
        radius
        deltaT
        type = 'circle'
    end
    
    methods
        function obj = Obstacle(arg)
            if nargin ~= 0
                N = size(arg.circleBlock, 1);
                obj(N) = obj;
                for o = 1:N
                   obj(o).position  = arg.circleBlock(o,1:2);
                   obj(o).velocity  = arg.circleBlock(o,3:4);
                   obj(o).radius    = arg.circleBlock(o,5);
                   obj(o).deltaT    = arg.deltaT;
                end
            end
        end
    end
        
    methods
        function obj = update(obj)
            obj.position = obj.position + obj.velocity*obj.deltaT;
        end
    end
    
    % status output function
    methods (Access = public)
        function state = outputStatus(obj)
            state = [obj.position, obj.velocity, obj.radius];
        end
    end
    
    methods
        function [x, y] = show(obj)
            i = 0:0.01:2*pi;
            x = obj.position(1) + obj.radius*cos(i);
            y = obj.position(2) + obj.radius*sin(i);
            coords = [x', y'];
            
            plot(polyshape(coords), 'FaceColor', 'black', 'LineStyle', 'none');
            
            if norm(obj.velocity)~= 0.0
                nextpos = obj.position + obj.velocity;
                plot([nextpos(1), obj.position(1)],[nextpos(2), obj.position(2)],...
                    'b-', 'LineWidth', 2);  
            end
            
        end
    end
end