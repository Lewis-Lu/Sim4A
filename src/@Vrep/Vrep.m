classdef Vrep
    
    properties
        sim
        clientID = 0
    end
    
    %% CONSTRUCTOR AND DECONSTRUCTOR
    methods
        function obj = Vrep()
            obj.sim=remApi('remoteApi');
            obj.sim.simxFinish(-1);
            obj.clientID = obj.sim.simxStart('127.0.0.1', 19997, true, true, 5000, 5);
            if obj.clientID > -1
                disp('successfully connected to the V-rep simulator.');
                disp(['clientID = ' num2str(obj.clientID)])
            else 
                disp('failed connected to the V-rep simulator.');
            end
        end
        
        
        function finish(obj)
            obj.sim.simxFinish(obj.clientID);
            disp('disconnected to the V-rep simulator.');
            obj.sim.delete();
        end
    end
    
    %% METHODS
    % APIs wrappers from the remote APIs provided by the CoppeliaSim
    methods(Access = public)
        function handle =  loadModel(obj, modelSubPath)
            % load custom-specific model from models root path
            modelPath = '/home/leiws/VREP/models/';
            modelPath = strcat(modelPath, modelSubPath);
            [rtn, handle] = obj.sim.simxLoadModel(obj.clientID, modelPath, 0, obj.sim.simx_opmode_blocking);
            if rtn ~= obj.sim.simx_return_ok
                disp(['the operation [loadModel] executed unfinedly. Return Code = ' num2str(rtn)])
            else
                disp([ 'handle[' num2str(handle) '] model loaded.'])
            end
        end
        
        
        function newCylinderHandle = copyAndPasteCylinderHandle(obj, newPos2D)
            [rtn, cylinderHandle] = obj.sim.simxGetObjectHandle(obj.clientID, 'Cylinder', obj.sim.simx_opmode_blocking);
            [~, cylinderPos] = obj.sim.simxGetObjectPosition(obj.clientID, cylinderHandle, -1, obj.sim.simx_opmode_blocking);
            if rtn == obj.sim.simx_return_remote_error_flag
                disp(['There is no ' copyObjectString ' in the scene.'])
            elseif rtn ~= obj.sim.simx_return_ok
                disp(['the operation [copyAndPaste] executed unfinedly. Return Code = ' num2str(rtn)])
            end
            [~, newCylinderHandle] = obj.sim.simxCopyPasteObjects(obj.clientID, cylinderHandle, obj.sim.simx_opmode_blocking);
            rtn = obj.sim.simxSetObjectPosition(obj.clientID, newCylinderHandle, -1, [newPos2D, cylinderPos(3)], obj.sim.simx_opmode_oneshot);
            if rtn ~= obj.sim.simx_return_ok
                disp(['the operation [setNewCylinder] executed unfinedly. Return Code = ' num2str(rtn)])
            end
        end
        
        
        function setPosition(obj, handle, position)
            pos = zeros(size(position));
            [rtn, curPos] = obj.sim.simxGetObjectPosition(obj.clientID, handle, -1, obj.sim.simx_opmode_blocking);
            if rtn ~= obj.sim.simx_return_ok
                disp(['the operation [GetPos] executed unfinedly. Return Code = ' num2str(rtn)])
            else
                pos(end) = curPos(end); % keep z-dim value unchanged for surface vehicle
                pos(1:end-1) = position(1:end-1);
                fprintf("Position to be set: [%f,%f,%f], handle = %d\n", pos(1), pos(2), pos(3), handle);
                rtn = obj.sim.simxSetObjectPosition(obj.clientID, handle, -1, pos, obj.sim.simx_opmode_blocking);
                if rtn ~= obj.sim.simx_return_ok
                    disp(['the operation [SetPos] executed unfinedly. Return Code = ' num2str(rtn)])
                end
            end
        end
        
        
        function handle = getLeftMotorHandle(obj, parentHandle)
            leftMotorChildIndex = 2;
            [rtn, handle] = obj.sim.simxGetObjectChild(obj.clientID, parentHandle, leftMotorChildIndex, obj.sim.simx_opmode_blocking);
            if rtn ~= obj.sim.simx_return_ok
                disp(['the operation [GetLeftMotorHandle] executed unfinedly. Return Code = ' num2str(rtn)])
            else
                fprintf("Object LeftMotor obtained, parentHandle number = %d\n", parentHandle);
            end
        end
        
        
        function handle = getRightMotorHandle(obj, parentHandle)
            rightMotorChildIndex = 1;
            [rtn, handle] = obj.sim.simxGetObjectChild(obj.clientID, parentHandle, rightMotorChildIndex, obj.sim.simx_opmode_blocking);
            if rtn ~= obj.sim.simx_return_ok
                disp(['the operation [GetRightMotorHandle] executed unfinedly. Return Code = ' num2str(rtn)])
            else
                fprintf("Object RightMotor obtained, parentHandle number = %d\n", parentHandle);
            end
        end
        
        
        function positionVec = getObjectPosition(obj, handle, varargin)
            if nargin == 2
                [rtn, positionVec] = obj.sim.simxGetObjectPosition(obj.clientID, handle, -1, obj.sim.simx_opmode_streaming);
                if rtn ~= obj.sim.simx_return_ok
                    disp(['the operation [getPosition] executed unfinedly. Return Code = ' num2str(rtn)])
                end
            elseif nargin == 3
                [rtn, positionVec] = obj.sim.simxGetObjectPosition(obj.clientID, handle, varargin{1}, obj.sim.simx_opmode_streaming);
                if rtn ~= obj.sim.simx_return_ok
                    disp(['the operation [getPosition] executed unfinedly. Return Code = ' num2str(rtn)])
                end
            else
                disp('[ERROR] Too many input variables')
            end
        end
        
        
        function orientationVec = getObjectOrientation(obj, handle, varargin)
            if nargin == 2
                % get orientation relativve to the absolute coordination
                [rtn, orientationVec] = obj.sim.simxGetObjectOrientation(obj.clientID, handle, -1, obj.sim.simx_opmode_streaming);
                if rtn ~= obj.sim.simx_return_ok
                    disp(['the operation [getOrientation] executed unfinedly. Return Code = ' num2str(rtn)])
                end
            elseif nargin == 3
                % get orientation relative to varargin{1}
                [rtn, orientationVec] = obj.sim.simxGetObjectOrientation(obj.clientID, handle, varargin{1}, obj.sim.simx_opmode_streaming);
                if rtn ~= obj.sim.simx_return_ok
                    disp(['the operation [getOrientation] executed unfinedly. Return Code = ' num2str(rtn)])
                end
            else
                disp('[ERROR] Too many input variables')
            end
        end
        
        
        function setOrientation(obj, handle, orientation)
            rtn = obj.sim.simxSetObjectOrientation(obj.clientID, handle, -1, orientation, obj.sim.simx_opmode_oneshot);
            if rtn ~= obj.sim.simx_return_ok
                disp(['the operation [setOrientation] executed unfinedly. Return Code = ' num2str(rtn)])
            end
        end
        
        
        function setJointVelocity(obj, jointHandle, velocity)
            obj.sim.simxSetJointTargetVelocity(obj.clientID, jointHandle, velocity, obj.sim.simx_opmode_streaming);
        end
        
        
        function setJointVelocityConsecutive(obj, jointHandle, velocity)
            % reserved function
            obj.sim.simxSetJointTargetVelocity(obj.clientID, jointHandle, velocity, obj.sim.simx_opmode_buffer);
        end
        
        
        function removeModel(obj, handles)
            num_handles = length(handles);
            if 0 == num_handles
                fprintf("[REMOVE] no model handle to remove.\n");
            else
                for i = 1:num_handles
                    obj.sim.simxRemoveModel(obj.clientID, handles(i), obj.sim.simx_opmode_oneshot);
                end
            end
        end
    end
end

