% zhou lvwen: zhou.lv.wen@gmail.com

function pple = getwalk(pple, cell, dt)
global walls rects pples exits circs;

% We want to walk towards our destination
% direction points from us to our destination
direction = unit(pple.dest- pple.center);
walk = pple.v*dt*direction;               % Scale to correct speed

ghost = pple;
ghost.center = ghost.center + walk;

% Do we run into object h walking in this direction?
if length(cell.rects)>0
    [dist, hitPt] = rectHit(ghost, rects(cell.rects));
    ghost = repelled(ghost, dist, hitPt);
end

% Do we run into object h walking in this direction?
if length(cell.circs)>0
    [dist, hitPt] = circHit(ghost, circs(cell.circs));
    ghost = repelled(ghost, dist, hitPt);
end

% Do we run into object h walking in this direction?
if length(cell.walls)>0
    [dist, hitPt] = wallHit(ghost, walls(cell.walls));
    ghost = repelled(ghost, dist, hitPt);
end


% Make a list of people near the current cell
neighbor = cell.pples(cell.pples~=ghost.id); 

% Break if nobody's here && Hit-test them against everybody nearby
if ~isempty(neighbor) && any( circHit(ghost, pples(neighbor))<0 ) 
    pple.stuck = 1;
    walk = [0, 0];
else
    walk = ghost.center - pple.center;
    % Now that we know the right direction in which to walk, walk there!
    pple.center = pple.center + walk; % Teleport in this direction (no inertia)
end

nnearby = cell.npples; % Number of People Nearby
% Check to see how much progress we've made towards this exit
pple.progress(nnearby)  = pple.progress(nnearby)  + dot(walk,direction);
pple.nprogress(nnearby) = pple.nprogress(nnearby) + 1;
%-----------------------------------------------------------------------

function pple = repelled(pple, dist, hitPt)
% Return the repulsion vector h delivers to us, if we are at newPos
if dist>0   % No hit would happen. 
    repulsion = 0;
else        % Make repulsion have length -hitDist
    repulsion = -dist*unit(pple.center-hitPt);
end
pple.center = pple.center+ repulsion.*(1+0.4*rand(1,2));

%-----------------------------------------------------------------------

function [dist, hitPt] = rectHit(ghost, rect)
% Find nearest furniture blocking our path (from c to dest)
v1 = cat(1,rect.v1); v3 = cat(1,rect.v3);
v2 = cat(1,rect.v2); v4 = cat(1,rect.v4);
[Dist,HitPt ] = distpoint2line(ghost, [v1;v2;v3;v4], [v2;v3;v4;v1]);
[dist,I] = min(Dist);
hitPt = HitPt(I,:);

%-----------------------------------------------------------------------

function [dist, hitPt] = circHit(ghost, circ)
% Find nearest furniture blocking our path (from c to dest)
HitPt = cat(1,circ.center);
Dist = sqrt((HitPt(:,1)-ghost.center(1)).^2+(HitPt(:,2)-ghost.center(2)).^2);
Dist = Dist - cat(1,circ.radius)- ghost.radius;
[dist,I] = min(Dist);
hitPt = HitPt(I,:);

%-----------------------------------------------------------------------

function [dist, hitPt] = wallHit(ghost, wall)
% Find nearest furniture blocking our path (from c to dest)
p1 = cat(1,wall.p1);
p2 = cat(1,wall.p2);
[Dist, HitPt] = distpoint2line(ghost, p1, p2);
[dist, I] = min(Dist);
hitPt = HitPt(I,:);
