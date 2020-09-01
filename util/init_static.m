%% init script
%%
clc;
clear; 
close all;

addpath('util');

%% system variables
global SHOW_SINGLE_AGENT_VO 
global SHOW_SINGLE_AGENT_VP 
global SHOW_ALL_AGENT_VELOCITY 
global PlotWhileSim

SHOW_SINGLE_AGENT_VO    = true;
SHOW_SINGLE_AGENT_VP    = false;
SHOW_ALL_AGENT_VELOCITY = false;
PlotWhileSim            = true;

%% arg
arg.simDimension        = 2; % 2-D simulation

arg.deltaT              = 0.1;

mapFile                 = 'maps/static.txt';
map                     = loadMap(mapFile);

arg.map = map;

% @agent       = map.agent;
% @obstacle    = map.circleBlock; 
% @polygon     = map.polygonBlock;

% @agent
arg.agent.N             = size(map.agent, 1);
arg.agent.position      = map.agent(:,1:2);
arg.agent.velocity      = map.agent(:,3:4);
arg.agent.radius        = map.agent(:,5);
arg.agent.goal          = map.agent(:,6:7);
% @circleObs
arg.obs.N               = size(map.circleBlock, 1);
arg.obs.position        = map.circleBlock(:,1:2);
arg.obs.velocity        = map.circleBlock(:,3:4);
arg.obs.radius          = map.circleBlock(:,5);
% @polygonObs
arg.polygon.N           = size(map.polygonBlock, 1);
arg.polygon.position    = map.polygonBlock(:,1:2);
arg.polygon.width       = map.polygonBlock(:,3);
arg.polygon.height      = map.polygonBlock(:,4);

if arg.agent.N ~= 0
    CONFIG.agents               = Agent(arg);
    CONFIG.trajectory.agents    = double.empty(0, 2*arg.agent.N);
    CONFIG.buffer.agents        = zeros(1, 2*arg.agent.N);
end
CONFIG.optVel                   = zeros(1, 2*arg.agent.N);

if arg.obs.N ~= 0
    CONFIG.obstacles            = Obstacle(arg);
    CONFIG.trajectory.obstacles = double.empty(0, 2*arg.obs.N);
    CONFIG.buffer.obstacles     = zeros(1, 2*arg.obs.N);
end
if arg.polygon.N ~= 0
    CONFIG.polygons             = Polygon(arg);
    CONFIG.trajectory.polygons  = double.empty(0, 2*arg.polygon.N);
    CONFIG.buffer.polygons      = zeros(1, 2*arg.polygon.N);
end

CONFIG.outputFilename   = 'test.gif'; % output animation filename

CONFIG.resFolderPath    = 'result';

CONFIG.objType          = cellstr(["agents", "obstacles", "polygons"]);

CONFIG.simEndFlag       = false;

CONFIG.simTime          = 0.0;

CONFIG.timeLimit        = 50.0;

CONFIG.deltaT           = arg.deltaT;

CONFIG.nearestDist      = double.empty(0, arg.agent.N);

CONFIG.buffer.nDist     = zeros(1, arg.agent.N);

CONFIG.timeSeries       = [];

CONFIG.voMethod         = 'Truncated'; % origin or truncated VO

CONFIG.opt_displacement = [[0,0];[-2,2];[-2,-2]];

CONFIG.leader_id        = 1;

CONFIG.cwdSignal        = 0;

CONFIG.formation_type   = 'position';

%% graph weighted matrix configuration
CONFIG.adjacantMatrix = ~eye(arg.agent.N).*1;
