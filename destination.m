% zhou lvwen: zhou.lv.wen@gmail.com

function pple = destination(pple, cell)
global walls exits rects circs;
nrects = length(rects);
ncircs = length(circs);

if pple.stuck   % If we were last stuck, flee the person we stuck to
    dest = pple.center + (rand(1,2)-0.5);
    pple.stuck = 0;
elseif pple.exit~=0 && ...     % We had an old destination && If we're still 
    (norm(pple.center-pple.dest)>4) && ... % a ways from our old destination
    rand<0.98                  % And this is most of the time
    dest = pple.dest;          % Keep old target (don't re-target)
else
    % Find the nearest visible exit
    pple.exit = bestexit(pple, cell.visexit);
    %pple.exit = bestexitWithNoVisibleList(pple);
    if pple.exit==0            % We didn't find any exits! 
        dest = 10*rand(1,2)-5; % Head in a random direction (wander)
    else                       % We found a good exit
        % First guess: head towards a proper point of nearest exit
        dest = selectpoint(exits(pple.exit), pple);
        
        % Make sure no furniture is in the way of the exit:
        rectmindist = inf; circmindist = inf;
        
        %Find nearest furniture blocking our path (from c to dest)
        if nrects>0
            [rectinway, rectcross, rectmindist] = rectInway(pple, dest);
        end     
        if ncircs>0
            [circinway, circcross, circmindist] = circInWay(pple, dest);
        end
        
        if rectmindist < circmindist     % square furniture
            % Find a way around this furniture
            dest = rectReRoute(pple, rects(rectinway), rectcross, cell);
        elseif rectmindist > circmindist % round furniture
            % Find a way around this furniture
            dest = circReRoute(pple, circs(circinway), circcross);
        end       
    end
end
pple.dest = dest;
pple.stuck = false;

%-----------------------------------------------------------------------

function dest = selectpoint(exit, pple)
if exit.strength<0 || norm(exit.center-pple.center)>4
    dest = exit.center;
else
    p1 = exit.p1; p2 = exit.p2;
    c = exit.center;
    d = pple.radius* unit(p1-p2);
    if norm(1.5*d)>norm(p1-c);
        dest = exit.center;
    else
        p1 = p1-(1.5+0.5*rand)*d;
        p2 = p2+(1.5+0.5*rand)*d;
        [dist, dest] = distpoint2line(pple, p1, p2);
    end
end

function best = bestexit(pple, list)
% Find the best exit for this pple
global exits;
if isempty(list)
    best = 0;
    return;
end
center = cat(1,exits(list).center);
x = center(:,1);
y = center(:,2);
strength = cat(1,exits(list).strength);
congestion = cat(1,exits(list).congestion);

dist = sqrt((x - pple.center(1)).^2 + (y-pple.center(2)).^2)/20;

% Strength of this exit, viewed from vantage.
strength = strength - 5*dist./(1+dist) - 5*congestion;
[maxval, bestid] = max(strength);
best = list(bestid);

%-----------------------------------------------------------------------

function best = bestexitWithNoVisibleList(pple)
global exits;
nexits = length(exits);
STRENGTH = -inf;
best = 0;
for i = 1:nexits
    if visible(exits(i).center, pple.center)
        congestion = exits(i).congestion;
        dist = norm(exits(i).center - pple.center)/20;
        strength = exits(i).strength - 5*dist./(1+dist) - 5*congestion;
        if strength>STRENGTH
            STRENGTH = strength;
            best = i;
        end
    end
end

function isvisible = visible(dest, source)
global walls;

p1 = cat(1,walls.p1);
p2 = cat(1,walls.p2);

if any(isintersect(dest, source, p1, p2))
    isvisible = false;
else
    isvisible = true;
end

%-----------------------------------------------------------------------
function [inway, cross, mindist] = rectInway(pple, dest)
% Does this object lie between the given person and their destination?
global rects;

v1 = cat(1,rects.v1); v3 = cat(1,rects.v3);
v2 = cat(1,rects.v2); v4 = cat(1,rects.v4);

[if1, p1] = isintersect(pple.center, dest, v1, v3);
[if2, p2] = isintersect(pple.center, dest, v2, v4);

d1 = sqrt(sum([p1(:,1)-pple.center(1), p1(:,2)-pple.center(2)].^2,2));
d2 = sqrt(sum([p2(:,1)-pple.center(1), p2(:,2)-pple.center(2)].^2,2));
if1x2 = if1&(~if2);
if2x1 = if2&(~if1);

% If they both intersected, we need to find the closer intersection.
if1a2 = if1&if2&(d1<d2); % Cross1 is closer to person
if2a1 = if1&if2&(d1>d2); % Cross2 is closer

dist = inf*ones(size(d1));
dist(if1x2) = d1(if1x2);
dist(if2x1) = d2(if2x1);
dist(if1a2) = d1(if1a2);
dist(if2a1) = d2(if2a1);

[mindist, k] = min(dist);
if if1x2(k)|if1a2(k)
    inway = k;
    cross = p1(k,:);
elseif if2x1(k)|if2a1(k)
    inway = k;
    cross = p2(k,:);
else
    inway = [];
    cross = [];
end

%-----------------------------------------------------------------------

function dest = rectReRoute(pple, rect, cross, cell)
% How should this person walk to get around this object to their destination?
global walls;

a = cross-rect.center;
a = (norm(rect.v(1,:)-rect.center)+pple.radius)*unit(a);
dest = a + rect.center;

if length(cell.walls)>0
    p1 = cat(1,walls(cell.walls).p1);
    p2 = cat(1,walls(cell.walls).p2);
    if any(isintersect(pple.center, dest, p1, p2))
        a = cross-rect.center;
        a(2)=-a(2);
        a = (norm(rect.v(1,:)-rect.center)+pple.radius)*unit(a);
        dest = a + rect.center;
    end
end

%-----------------------------------------------------------------------

function [inway, cross, mindist]=circInWay(pple, dest)
% Does this object lie between the given person and their destination?
global circs
a = dest-pple.center; % a points from p to target
circcenter = cat(1,circs.center);
circradius = cat(1,circs.radius);

% b points from p to our center
b = [circcenter(:,1)-pple.center(1), circcenter(:,2)-pple.center(2)];
d = (b*a')/dot(a,a);
d = [a(1)*d a(2)*d];

dist = sqrt(sum(d.^2,2));
dotad = d*a';
% Nearest point to our center on line p-dest
nearest = [pple.center(1) + d(:,1) pple.center(2) + d(:,2)];
R = sqrt(sum((circcenter-nearest).^2,2)) - circradius - pple.radius;

I = find((dotad>=0)&(R<0));
if ~isempty(I) % If person's path intersects us
    [mindist, J] = min(dist(I));
    inway = I(J); % we're in the way
    cross = nearest(inway,:);
else % The nearest point is behind us already
    mindist = inf;
    inway = [];
    cross = [];
end

%-----------------------------------------------------------------------

function dest = circReRoute(pple, circ, cross)
% How should this person walk to get around this object to their destination?
%a = dest - pple.center; % a points from p to target
%b = circ.center- pple.center;% b points from p to our center
% Nearest now points from c to closest approach
a = cross -circ.center; 
nearest = (circ.radius+pple.radius)*unit(a);
dest = nearest + circ.center;
