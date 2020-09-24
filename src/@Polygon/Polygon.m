% class definition file for 'Polygon'
% 
% Written by Lu, Hong
% luhong@westlake.edu.cn
% 

classdef Polygon
    % Polygon
    properties
        position
        width
        height
        type = 'polygon'
        radius = 0
        velocity = [0.0, 0.0] % static as default
    end
    
    properties (Access = public)
        Vertices
    end
    
    methods
        function obj = Polygon(arg)
            if nargin ~= 0
                N = size(arg.polygonBlock, 1);
                obj(N) = obj;
                for o = 1:N
                   obj(o).position  = arg.polygonBlock(o,1:2);
                   obj(o).width     = arg.polygonBlock(o,3);
                   obj(o).height    = arg.polygonBlock(o,4);
                   obj(o).radius    = sqrt(sum(obj(o).width^2, obj(o).height^2));
                   % ---radius placeholder---
                end
            end
        end
    end
    
    % status output function
    methods (Access = public)
        function obj = update(obj)
            obj.position = obj.position + obj.velocity;
        end
    end
    
    methods
        function show(obj)
            obj.Vertices = zeros(4,2);
            obj.Vertices(1,:) = obj.position + [-obj.width, obj.height];
            obj.Vertices(2,:) = obj.position + [obj.width, obj.height];
            obj.Vertices(3,:) = obj.position + [obj.width, -obj.height];
            obj.Vertices(4,:) = obj.position + [-obj.width, -obj.height];
            plot(polyshape(obj.Vertices), 'FaceColor', 'red', 'LineStyle', 'none', 'FaceAlpha', 0.8);
        end
    end
end