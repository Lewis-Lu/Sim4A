classdef Vrep
    
    properties
        vrep
        clientID = 0
    end
    
    %% CONSTRUCTOR AND DECONSTRUCTOR
    methods
        function obj = Vrep(port)
            obj.vrep=remApi('remoteApi');
            obj.vrep.simxFinish(-1);
            obj.vrep.simxSynchronous(obj.clientID, true);
            obj.clientID = obj.vrep.simxStart('127.0.0.1', port, true, true, 5000, 5);
            if obj.clientID > -1
                disp('successfully connected to the V-rep simulator.');
                disp(['clientID = ' num2str(obj.clientID)])
            else 
                disp('failed connected to the V-rep simulator.');
            end
        end
        
        function finish(obj)
            obj.vrep.simxFinish(obj.clientID);
            disp('disconnected to the V-rep simulator.');
        end
    end
    
    %% METHODS
    methods
        function handles = getSpecifiedObjectList(obj, modelName)
            handles = [];
        end
        
        
        function handle =  loadModel(obj, x, y, z)
            modelPath = '/home/leiws/VREP/models/robots/mobile/e-puck.ttm';
            [rtn, handle] = obj.vrep.simxLoadModel(obj.clientID, modelPath, 0, obj.vrep.simx_opmode_blocking);
            if rtn ~= 0
                disp(['the operation executed unfinedly. Return Code = ' num2str(rtn)])
            else
                disp([ 'handle[' num2str(handle) '] model loaded.'])
            end
            rtn = obj.vrep.simxSetObjectPosition(obj.clientID, handle, -1, [x,y,z], obj.vrep.simx_opmode_blocking);
            if rtn ~= 0
                disp(['[Set POSITION][RTNCODE]  ' num2str(rtn) '  <<< .']);
            end
        end
    end
end

