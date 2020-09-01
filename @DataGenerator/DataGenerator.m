classdef DataGenerator
    %DATAGENERATOR 
    % This is class is used for generate map data for training to determine
    % the local minima
    
    properties
        num_map;
        pixInterval;
    end
    
    methods
        function obj = DataGenerator(num_map, horizon)
            obj.num_map = num_map;
            obj.pixInterval = horizon;
        end
    end
    
    methods
        function stochasticMapGenerator(obj)
            % stochastically generate maps with size 100m*100m
            size = 100;
            num_circleBlock = floor(rand*50);
            num_polygonBlock = floor(rand*1000);

            arg.deltaT = 0.01;

            for p = 1:obj.num_map

                arg.circleBlock = zeros(num_circleBlock, 5);
                arg.polygonBlock = zeros(num_polygonBlock, 4);

                rng shuffle

                arg.circleBlock(:,5)      = 1.0;
                arg.circleBlock(:,1:2)    = rand(num_circleBlock, 2)*size;

                rng shuffle

                arg.polygonBlock(:,1:2)    = rand(num_polygonBlock, 2)*size;
                arg.polygonBlock(:,3)      = 1.0;
                arg.polygonBlock(:,4)      = 1.0;


                circleBlock = Obstacle(arg);
                polygonBlock = Polygon(arg);

                f = figure;
                axis([0 size 0 size]);

                axis equal; axis off;
                hold on;

                for i = 1:num_circleBlock
                    circleBlock(i).show();
                end
                for i = 1:num_polygonBlock
                    polygonBlock(i).show();
                end
                saveas(f, ['stochasticEnv/env_' num2str(p) '.png']);
                close gcf;
            end
        end
        
        function mapSplitter(obj)
            folderPath = 'stochasticEnv/';
            dataFolderPath = 'trainDataset/';
            files = dir([folderPath 'env_*.png']);
            
            system('rm -r trainDataset/*.png')
            
            fprintf("Generating dataset in the folder TRAINDATASET.\n");
            
            index = 0;
            for i = 1:size(files, 1)
               im = rgb2gray(imread([folderPath files(i).name]));
               h = floor(size(im,1)/obj.pixInterval);
               w = floor(size(im,2)/obj.pixInterval);
               for j = 1:h
                   for k = 1:w
                       heightIndexFront = (j-1)*obj.pixInterval+1;
                       heightIndexRear  = j*obj.pixInterval;
                       widthIndexFront  = (k-1)*obj.pixInterval+1;
                       widthIndexRear   = k*obj.pixInterval;
                       temporaryIm = im(heightIndexFront:heightIndexRear,widthIndexFront:widthIndexRear);
                       index = index + 1;
                       imFileName = [dataFolderPath num2str(index) '.png'];
                       imwrite(temporaryIm, imFileName);
                   end
               end
            end
            
            fprintf("Generating finished.\n");
        end
        
    end
end

