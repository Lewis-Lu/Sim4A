clc; close all;

mexCommand

parameters = [];
L = 60;
%--------------Narrow Cross senario---------
% 25 agents
pipeWidth = 20;
agents = []; goals = [];
paddingX = 10; paddingY = 10;
initalX = -L-2*paddingX; initalY = 2*paddingY;
for i = 1:5
    rowY = initalY - (i-1)*paddingY;
    for j = 1:5
        posx = initalX + (j-1)*paddingX;
        posy = rowY;
        agents = [agents, [posx; posy]];
        goals  = [goals, [-posx; posy]];
    end
end
obstacles = [[5;pipeWidth/2;5;L;-5;L;-5;pipeWidth/2], ...
    [5;-L;5;-pipeWidth/2;-5;-pipeWidth/2;-5;-L]];
filename = ['gif/rvoGen-Pipe-Senario.gif'];
%--------------Narrow Cross senario---------
% %------------circle senario-------
% filename = ['gif/rvoGen-Circle-Senario.gif'];
% i = 0 : 0.22 : 2*pi;
% posCircleX = 20*cos(i);
% posCircleY = 20*sin(i);
% agents = [];
% goals = [];
% obstacles = [];
% radius = 2;
% N = max(size(i));
% for i = 1:N
%     agents = [agents, [posCircleX(i); posCircleY(i)]];
%     goals = [goals, [-posCircleX(i); -posCircleY(i)]];
% end
% %------------circle senario-------
[timestep, traj, radius] = rvoGen(agents, obstacles, goals, parameters);

plotting(timestep, traj, obstacles, radius, filename, L);
