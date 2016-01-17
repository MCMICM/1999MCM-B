% main.m
%
% This is the main script for pedestrian simulation. The simulation is base
% on 1999 MCM outstanding paper from team 375.
%    Team Members: Orion Lawlor, Jason Tedor and Gregg Christopher
%    Paper title:  Room Capacity Analysis Using a Pair of Evacuation Models
%    UMAP Journal;Fall1999, Vol. 20 Issue 3, p321
%
% The original C++ simulation code of the team 375 can be down from:   
%    http://www.cs.uaf.edu/~olawlor/projects/1999/mcm_99/
% 
% Variables and parameters are defined as below
%   walls    = One straight line segment, comprising a barrier to travel and sight.
%   nwalls   = length(walls), number of walls
%   exits    = An exit is a wall that eats people
%   nexits   = length(exits), number of exits
%   rects    = A piece of rectangle furniture, like a desk
%   nrects   = length(rects), number of rectangle furniture
%   circs    = A piece of round furniture
%   ncircs   = length(circs), number of round furniture
%   pples    = A person is basically a piece of round furniture that moves
%   npples   = length(pples), number of people
%   domain   = [xmin xmax ymin ymax]
%   cells    = 
%   cellsize = cell size
%   ncell    = [nx ny]
%   time     = current time of the system
%   dt       = time step
%   
%   
%
% zhou lvwen: zhou.lv.wen@gmail.com
%

clear; clc
global walls exits rects pples circs;
global xmin ymin xmax ymax;
global cellsize ncell;

rand('seed',44);%44: 46.8
cellsize = 3; % ft
dt = 0.2;     % s
time = 0;
%                  44         44        46      39
% scenarios = auditorium/ gymnasium/ ballroom/ pool/ classroom/ test
[walls,exits,rects,circs,pples,h,domain] = scenarios('auditorium');
xmin = domain(1); xmax = domain(2); ymin = domain(3); ymax = domain(4);
ncell = ceil([xmax - xmin, ymax - ymin]./cellsize);
cells = cellsinfo([],'walls','exits','rects','circs','visexit','neighbor');

nleave = 0;
npples = length(pples);

while nleave < npples
    % Update time
    time = time + dt; 
    
    % Update the pples cell and  exit congestion
    cells = cellsinfo(cells,'pples', 'congestion');
    
    for i = 1:npples
        % Skip the pedestrians who have already arrived at exit
        if pples(i).exitime; continue; end
        
        pple = pples(i);
        
        % Get the cell that the pple located at.
        cell = cells(pple.cell(1), pple.cell(2));
        
        % Pick a destination
        pple = destination(pple, cell);
        
        % Plan one step to the destination: 
        % if a wall or furniture impedes our next step, plan a shorter step.
        % if other people impede our next step, don’t move.
        pple = getwalk(pple, cell, dt);
        
        % If we have reached exit, set person's exitime as current time
        [pple, nleave] = leave(pple, nleave, time);
        
        pples(i) = pple;
    end 
    
    % update the handle's XData and YData as pples.center changed.
    pplecenter = cat(1,pples.center);
    set(h,'XData',pplecenter(:,1),'YData',pplecenter(:,2));
    drawnow
end

[nnearby,speed,nspeed, ti,npplein] = statisticalPlot(pples, time, dt, ...
    cellsize,'speed vs crowding','number of people vs time');
