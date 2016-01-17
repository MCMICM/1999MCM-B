% zhou lvwen: zhou.lv.wen@gmail.com

function [walls,exits,rects,circs,pples,h,domain] = scenarios(name,ifwrite)
% scenarios generate a disaster scenarios, include walls, exits, furniture 
%   and people.
%
% name = name of scenarios. name can be auditorium/gymnasium/ballroom/pool
%        /classroom OR your filename.
% ifwrite = if write the scenarios to a file.
%

if nargin<3; ifwrite = 0; end
nwalls = 0; % number of walls
nexits = 0; % number of exits
nrects = 0; % number of rectangles
ncircs = 0; % number of circles
npples = 0; % number of people

switch(name)
    case 'auditorium'
        sketch = [...
            '%%%% Auditorium simulation: 99.32%% Capacity     \n', ...
            '%%       _________                               \n', ...
            '%%      |  o |  | ---------____________          \n', ...
            '%%      |  o |o |o |  |  |  |          |         \n', ...
            '%%     _|  o |o |o |o |o |o |o         |         \n', ...
            '%%                 |o |o |o |o         |_        \n', ...
            '%%     _     |o |o                      _        \n', ...
            '%%      |  o |o |o |o |o |o |o    []  [|         \n', ...
            '%%      |  o |o |o |o |o |o |o    []o [|         \n', ...
            '%%      |  o |o |o |o |o |o |o    []o [|         \n', ...
            '%%      |  o |o |o |o |o |o |o    []o [|         \n', ...
            '%%     _|  o |o |o |o |o |o |o    []  [|_        \n', ...
            '%%           |o |o                      _        \n', ...
            '%%     _           |o |o |o |o         |         \n', ...
            '%%      |  o |o |o |o |o |o |o         |         \n', ...
            '%%      |  o |o |o |  |  | _|__________|         \n', ...
            '%%      |__o_|__|__--------                      \n', ...
            '%%                                               \n'];
        
        X = [ 6.00  5.00  5.00  6.00  6.00 48.00 48.00 49.00 49.00 48.00];
        Y = [13.00 13.00 19.00 19.00 25.00 20.25 16.25 16.25 10.25 10.25];
        X = [X  fliplr(X) X(1)]; 
        Y = [Y -fliplr(Y) Y(1)];
        W = [1 0 1 1 1 1 1 0 1 1 1 0 1 1 1 1 1 0 1 1];% is wall or exit ?
        
        %% walls and exits
        for i = 1:length(W)
            if W(i)
                nwalls = nwalls + 1;
                walls(nwalls) = wall([X(i), Y(i)], [X(i+1), Y(i+1)]);
            else
                nexits = nexits + 1;
                exits(nexits) = exit([X(i), Y(i)], [X(i+1), Y(i+1)], 1, 20);
            end
        end
           
        %% rectangles
        % Instructor table
        nrects = nrects + 1;
        rects(nrects) = rect([43.5, 0], [2, 20]);
        
        % Rows of Chairs
        chairwid = 0.1;     % for all chairs
        chairlen = 5.9;     % just for side chairs
        chairlen27 = 27.25; % lenght of the middle chair at x = 27;
        dY=(Y(6)-Y(5))/(X(6)-X(5));
        for xi = 39:-3:9
            % middle
            nrects = nrects + 1;
            rects(nrects) = rect([xi, 0], [chairwid, chairlen27+2*(xi-27)*dY]);
            % right
            nrects = nrects + 1;
            yu = interp1(X(5:6),Y(5:6),xi);
            yi = yu - chairlen/2 + chairwid*dY;
            rects(nrects) = rect([xi, yi], [chairwid, chairlen]);
            % left
            nrects = nrects + 1;
            rects(nrects) = rect([xi,-yi], [chairwid, chairlen]);
        end
        
        % lenght of the middle chair at last row
        chairlen12 = rects(nrects-5).size(2);
        chairlen13 = interp1([X(1),12],[2*Y(1),chairlen12],9);
        rects(nrects-2) = rect(rects(nrects-2).center, [chairwid, chairlen13]);
        
        %% person     
        % Instructors
        for yi = -4:4:4
            npples = npples + 1;
            pples(npples) = person([46.5, yi]);
        end
        
        % Students
        Dyperson = 5/3;
        Dyperson2wall = 1;
        n = [ 4  4  4  4  4  4  4  4  4  4  4  4  % left
             18 18 17 17 17 16 16 15 15 15 14 14  % middle
              4  4  4  4  4  4  4  4  4  4  4  4];% right
        x = 7.5:3:40.5;
        yr = interp1(X(5:6),Y(5:6),x) - Dyperson2wall;
        yl = - yr;
        for i = 1:length(n)
            nl = n(1,i); nr = n(3,i); nc = n(2,i);
            for j = 0:nl-1 % left
                npples = npples + 1;
                pples(npples) = person([x(i), yl(i)+j*Dyperson]);
            end
            for j = 0:nr-1 % right
                npples = npples + 1;
                pples(npples) = person([x(i), yr(i)-j*Dyperson]);
            end
            for j = 0:nc-1 % middle
                npples = npples + 1;
                pples(npples) = person([x(i), (2*j-nc+1)/2 * Dyperson]);
            end
        end
        
    case 'gymnasium'   
        sketch = [...
            '%%%% Gymnasium simulation: 230%% legal capacity  \n', ...
            '%%       ______________________________          \n', ...
            '%%      |                              |         \n', ...
            '%%      |  o o o o o o o o o o o o o o |         \n', ...
            '%%     _| o o o o o o o o o o o o o o  |         \n', ...
            '%%         o o o o o o o o o o o o o o |_        \n', ...
            '%%     -| o o o o o o o o o o o o o o   _        \n', ...
            '%%     _   o o o o o o o o o o o o o o |         \n', ...
            '%%      | o o o o o o o o o o o o o o  |         \n', ...
            '%%      |  o o o o o o o o o o o o o o |         \n', ...
            '%%     _| o o o o o o o o o o o o o o  |         \n', ...
            '%%         o o o o o o o o o o o o o o |_        \n', ...
            '%%     -| o o o o o o o o o o o o o o   _        \n', ...
            '%%     _   o o o o o o o o o o o o o o |         \n', ...
            '%%      | o o o o o o o o o o o o o o  |         \n', ...
            '%%      |  o o o o o o o o o o o o o o |         \n', ...
            '%%      |______________________________|         \n', ...
            '%%                                               \n'];
            
        X = [ 6   5   5   6   6   5   5   6   6 120 120 121 121 120];
        Y = [11  11  17  17  20  20  26  26  64  64  30  30  24  24];
        X = [X  fliplr(X) X(1)]; 
        Y = [Y -fliplr(Y) Y(1)];
        % is wall or exit ?
        W = [1 0 1 1 1 0 1 1 1 1 1 0 1 1 1 0 1 1 1 1 1 0 1 1 1 0 1 1];
        
        %% walls and exits
        for i = 1:length(W)
            if W(i)
                nwalls = nwalls + 1;
                walls(nwalls) = wall([X(i), Y(i)], [X(i+1), Y(i+1)]);
            else
                nexits = nexits + 1;
                exits(nexits) = exit([X(i), Y(i)], [X(i+1), Y(i+1)], 1, 20);
            end
        end
        %%% exit sign
        %exitsign = [115 -13 -1 30; 
        %            115  35 -1 30; 
        %            9    33 -1 30; 
        %            9    23 -1 30; 
        %            9    -5 -1 30; 
        %            9   -15 -1 30];
        %for i = 1:length(exitsign);
        %    nexits = nexits + 1;
        %    center = exitsign(i,1:2);
        %    strength = exitsign(i,3);
        %    diameter = exitsign(i,4);
        %    exits(nexits) = exit(center,center,strength, diameter);
        %end
        
        %% people
        Dperson = 3.4;
        [x, y] = meshgrid(10:Dperson:115.4, -57:Dperson:55.2);
        x = [x(:); x(:) + Dperson/2];
        y = [y(:); y(:) + Dperson/2];
        
        for i = 1:length(x)
            npples = npples + 1;
            pples(npples) = person([x(i), y(i)]);
        end
        
    case 'ballroom'
        sketch = [...
            '%%%% Wood Center Ballroom: 100%% capacity        \n', ...
            '%%                                               \n', ...
            '%%       ____| | | | | | | |___________          \n', ...
            '%%      |                              |         \n', ...
            '%%      |    o           o             |         \n', ...
            '%%      |  o(+)o       o(+)o           |         \n', ...
            '%%      |    o     o     o     o       |         \n', ...
            '%%      |        o(+)o       o(+)o     |         \n', ...
            '%%      |    o     o     o     o       |         \n', ...
            '%%      |  o(+)o       o(+)o           |         \n', ...
            '%%      |    o     o     o      o      |         \n', ...
            '%%      |        o(+)o        o(+)o    |         \n', ...
            '%%      |    o     o      o     o      |         \n', ...
            '%%      |  o(+)o        o(+)o          |_        \n', ...
            '%%      |    o            o             _        \n', ...
            '%%      |______________________________|         \n', ...
            '%%                                               \n'];

		X = [14  6   6  65  65  66  66  65  65  44  44];
        Y = [62 62   6   6   7   7  10  10  62  62  65];
        W = [  1   1   1   1   1   0   1   1   1   1  ];
		%% walls and exits
        for i = 1:length(W)
            if W(i)
                nwalls = nwalls + 1;
                walls(nwalls) = wall([X(i), Y(i)], [X(i+1), Y(i+1)]);
            else
                nexits = nexits + 1;
                exits(nexits) = exit([X(i), Y(i)], [X(i+1), Y(i+1)], 1.0, 20);
            end
        end
        
        for xi = 14:3:41
            nwalls = nwalls + 1;
            walls(nwalls) = wall([xi, 62], [xi, 65]);
            
            nexits = nexits + 1;
            exits(nexits) = exit([xi, 65], [xi+3, 65], 1, 6);
        end
        
        %% exit sign
        nexits = nexits + 1;
        exits(nexits) = exit([43, 60 ], [39, 60 ], -0.1, 6);
        nexits = nexits + 1;
        exits(nexits) = exit([63, 8.5], [63, 8.5], -0.1, 6);
        
        %% person and circles (table)
        dpt = 4; % distance between people and table;
        [x, y] = meshgrid(13:8:53, 13:16:45);
        y(:,2:2:end) = y(:,2:2:end) + 8;
        x = x(:); y = y(:);
        for i = 1:length(x)
            ncircs = ncircs + 1;
            circs(ncircs) = circ([x(i), y(i)], 3);
            
            for theta = 0:pi/4:2*pi-pi/4;
                npples = npples  + 1;
                rx = dpt*cos(theta); ry = dpt*sin(theta);
                pples(npples) = person([x(i)+rx, y(i)+ry]);
            end
        end
   
    case 'pool'
        sketch = [...
            '%%%% Pool                                        \n', ...
            '%%       _______| |____________| |_____          \n', ...
            '%%      |                              |         \n', ...
            '%%      |                              |         \n', ...
            '%%      |                              |         \n', ...
            '%%      |      ___________________     |         \n', ...
            '%%     _|      |                  |    |         \n', ...
            '%%             |       pool       |    |         \n', ...
            '%%     _       |                  |    |         \n', ...
            '%%      |      |__________________|    |         \n', ...
            '%%      |      ooooooooooooooooooo     |         \n', ...
            '%%      |                              |         \n', ...
            '%%      |      ooooooooooooooooooo     |         \n', ...
            '%%      |      ooooooooooooooooooo     |         \n', ...
            '%%      |      ooooooooooooooooooo     |         \n', ...
            '%%      |______________________________|         \n', ...
            '%%                                               \n'];
            
        X = [5 113 113  98  93  26  21  5    5  5  5];
        Y = [5   5  80  80  80  80  80  80  41  36 5];
        W = [  1   1   1   0   1   0   1   1   0  1 ];
        %% walls and exits
        for i = 1:length(W)
            if W(i)
                nwalls = nwalls + 1;
                walls(nwalls) = wall([X(i), Y(i)], [X(i+1), Y(i+1)]);
            else
                nexits = nexits + 1;
                exits(nexits) = exit([X(i), Y(i)], [X(i+1), Y(i+1)], 1, 20);
            end
        end
        
        %% rectangles
        % pool
        nrects = nrects + 1;
        rects(nrects) = rect([59, 42.5], [78, 45]);
        
        %% person
        [x, y] = meshgrid(20:4:92, [8,10,13,18]);
        x = x(:); y = y(:);
        for i = 1:length(x)
            npples = npples + 1;
            pples(npples) = person([x(i), y(i)]);
        end
        
    case 'classroom'
        sketch = [...
            '%%%% class room                                  \n', ...
            '%%      |------------------------------|         \n', ...
            '%%      |        []o[]o[]o[]o[]o[]o    |         \n', ...
            '%%      |__      []o[]o[]o[]o[]o[]o    |         \n', ...
            '%%      |  |                           |         \n', ...
            '%%      |  |_    []o[]o[]o[]o[]o[]o    |         \n', ...
            '%%      |  | |   []o[]o[]o[]o[]o[]o    |         \n', ...
            '%%      |  | |                         |         \n', ...
            '%%      |  |_|   []o[]o[]o[]o[]o[]o    |         \n', ...
            '%%      |  |     []o[]o[]o[]o[]o[]o    |         \n', ...
            '%%      |__|                           |         \n', ...
            '%%      |        []o[]o[]o[]o[]o[]o    |         \n', ...
            '%%      |        []o[]o[]o[]o[]o[]o    |         \n', ...
            '%%      |  __________________________  |         \n', ...
            '%%                                               \n'];
        X = [  0  3   30  33 33  0  0 ];
        Y = [-13 -13 -13 -13 13 13 -13];
        W = [   0   1   0   1  1   1  ];
        %% walls and exits
        for i = 1:length(W)
            if W(i)
                nwalls = nwalls + 1;
                walls(nwalls) = wall([X(i), Y(i)], [X(i+1), Y(i+1)]);
            else
                nexits = nexits + 1;
                exits(nexits) = exit([X(i), Y(i)], [X(i+1), Y(i+1)], 1, 20);
            end
        end
        
        %% rectangles and people
        % Instructor table
        nrects = nrects + 1;
        rects(nrects) = rect([3, 0], [1.6, 3]);
        % teacher
        npples = npples + 1;
        pples(npples) = person([1.2, 0]);
        
        % desk and students
        desklen = 4.0; deskwid = 1.5;
        [x,y] = meshgrid(6.5:3.5:24,-2.625*desklen:1.75*desklen:2.625*desklen);
        x = x(:)+deskwid/2; y = y(:);
        for i = 1:length(x)
           nrects = nrects + 1; 
           rects(nrects) = rect([x(i), y(i)], [deskwid, desklen]);
           
           npples = npples + 1;
           pples(npples) = person([x(i)+deskwid, y(i)-desklen/4]);
           npples = npples + 1;
           pples(npples) = person([x(i)+deskwid, y(i)+desklen/4]);
        end
        nrects = nrects + 1;
        xi = 27.5+deskwid/2; yi =  -0.875*desklen;
        rects(nrects) = rect([xi, yi], [deskwid, desklen]);
        
        npples = npples + 1;
        pples(npples) = person([xi+deskwid/2+1, yi-desklen/4]);
        npple = npples + 1;
        pples(npples) = person([xi+deskwid/2+1, yi+desklen/4]);
    case 'test'
        sketch = [...
            '%%%% Pool                                        \n', ...
            '%%                                               \n', ...
            '%%      |                                        \n', ...
            '%%      |                                        \n', ...
            '%%      |                                        \n', ...
            '%%      |                  oooooooo              \n', ...
            '%%      |                  oooooooo              \n', ...
            '%%      |                  oooooooo              \n', ...
            '%%      |              _   oooooooo              \n', ...
            '%%      |             | |  oooooooo              \n', ...
            '%%     _|             |_|  oooooooo              \n', ...
            '%%     _                   oooooooo              \n', ...
            '%%      |                                        \n', ...
            '%%      |                                        \n', ...
            '%%      |                                        \n', ...
            '%%                                               \n'];
        
        %% walls
        nwalls = nwalls + 1;
        walls(nwalls) = wall([10, 0], [10,15]);
        nwalls = nwalls + 1;
        walls(nwalls) = wall([10,15], [ 5,15]);
        nwalls = nwalls + 1;
        walls(nwalls) = wall([ 5,20], [10,20]);
        nwalls = nwalls + 1;
        walls(nwalls) = wall([10,20], [10,100]);
        
        %% exits and exit signs
        nexits = nexits + 1;
        exits(nexits) = exit([14,15], [14, 15], -1, 20);
        nexits = nexits + 1;
        exits(nexits) = exit([ 5,15], [ 5, 20],  1, 20);
        
        %% rect
        nrects = nrects + 1;
        rects(nrects) = rect([40, 25], [3,8]);
        
        %% circ
        ncircs = ncircs + 1;
        circs(ncircs) = circ([40,50], 4);
        
        %% person
        [x,y] = meshgrid(55:4:85, [20:4:45 60:4:85]);
        for i = 1:length(x(:))
            npples = npples + 1;
            pples(npples) = person([x(i), y(i)]);
        end
         
         
         
    otherwise
        sketch = ['%%%% ', name, '\n'];
        [walls, exits, rects, circs, pples] = readscenarios(name);
        nwalls = length(walls);
        nexits = length(exits);
        nrects = length(rects);
        ncircs = length(circs);
        npples = length(pples);
end

if nwalls == 0; walls = []; end;
if nexits == 0; exits = []; end;
if nrects == 0; rects = []; end;
if ncircs == 0; circs = []; end;
if npples == 0; pples = []; end;

for i = 1:npples
    pples(i).id = i;
end

% draw
[h, domain] = drawscenarios(walls, exits, rects, circs, pples);

% print to file
if ifwrite
    printscenarios(name,sketch,walls,exits,rects,circs,pples)
end

%-----------------------------------------------------------------------

function [h, domain]= drawscenarios(walls, exits, rects, circs, pples)
%% draw
figure
subplot('position',[0.05,0.05,0.9,0.9])
hold on; box on;

% draw walls
nwalls = length(walls);
if nwalls > 0
    p1 = cat(1, walls.p1);
    p2 = cat(1, walls.p2);
    hw = plot([p1(:,1) p2(:,1)]',[p1(:,2), p2(:,2)]', 'k','linewidth',2);
end

% draw exits and exitsign
nexits = length(exits);
if nexits > 0
    strength = cat(1,exits.strength);
    realexit = exits(strength>0);
    exitsign = exits(strength<0);
    if length(realexit)>0
        p1 = cat(1, realexit.p1);
        p2 = cat(1, realexit.p2);
        he = plot([p1(:,1) p2(:,1)]',[p1(:,2), p2(:,2)]','b:','linewidth',2);
    end
    if length(exitsign)>0
        p1 = cat(1, exitsign.p1);
        p2 = cat(1, exitsign.p2);
        hs = plot(p1(:,1), p1(:,2),'b>');
    end
end

% draw rectangles
nrects = length(rects);
if nrects > 0
   v = [rects.v];
   hr = fill(v(:,1:2:end), v(:,2:2:end),[0.8,0.8,0.8]);
end

% draw circles
ncircs = length(circs);
theta = 0:pi/72:2*pi;
for i = 1:ncircs
    radius = circs(i).radius;
    xc = circs(i).center(1);
    yc = circs(i).center(2);
    x = xc+radius*cos(theta);
    y = yc+radius*sin(theta);
    hc(i) = fill(x, y, [0.8,0.8,0.8]);
end
% draw people
npples = length(pples);
if npples > 0
    pcenter = cat(1,pples.center);
    h = plot(pcenter (:,1),pcenter(:,2),'or','markersize',6);
end
axis image
XLIM = get(gca,'Xlim'); 
YLIM = get(gca,'Ylim');
xmin = 3*round(XLIM(1)/3)-3; xmax = 3*round(XLIM(2)/3)+3;
ymin = 3*round(YLIM(1)/3)-3; ymax = 3*round(YLIM(2)/3)+3;
domain = [xmin, xmax, ymin, ymax];
axis([xmin xmax ymin ymax])
axis off
hold off

%-----------------------------------------------------------------------

function printscenarios(fname,sketch,walls,exits,rects,circs,pples)
%% write to file
path = './scenarios/';
if ~isdir(path); mkdir(path); end;
fid = fopen([path,fname],'w');
fprintf(fid,sketch);

nwalls = length(walls);
if nwalls > 0;
    fprintf(fid, pformat('wall','s',4), 'x1','y1','x2','y2');
    for i = 1:nwalls
        x1 = walls(i).p1(1); y1 = walls(i).p1(2);
        x2 = walls(i).p2(1); y2 = walls(i).p2(2);
        fprintf(fid, pformat('wall','f',4), x1, y1, x2, y2);
    end
end

nexits = length(exits);
if nexits > 0;
    realexit = exits([exits.strength]>0);
    exitsign = exits([exits.strength]<0);
    if length(realexit)>0
        fprintf(fid,pformat('exit','s',6),'x1','y1','x2','y2','str.','diam.');
    end
    for i = 1:length(realexit)
        x1 = realexit(i).p1(1); y1 = realexit(i).p1(2);
        x2 = realexit(i).p2(1); y2 = realexit(i).p2(2);
        strength = realexit(i).strength;
        diameter = realexit(i).diameter;
        fprintf(fid, pformat('exit','f',6),x1,y1,x2,y2,strength,diameter);
    end
    
    if length(exitsign)>0
        fprintf(fid, pformat('sign','s',4), 'x','y','str.','diam.');
    end
    for i = 1:length(exitsign)
        x = exitsign(i).p1(1); y = exitsign(i).p1(2);
        strength = exitsign(i).strength;
        diameter = exitsign(i).diameter;
        fprintf(fid, pformat('sign','f',4), x, y,strength,diameter);
    end
    
end

nrects = length(rects);
if nrects > 0
    fprintf(fid, pformat('rect','s',4),'xc','yc','width','length');
    for i = 1:nrects
        xc = rects(i).center(1); yc = rects(i).center(2);
        wid = rects(i).size(1);
        len = rects(i).size(2);
        fprintf(fid,pformat('rect','f',4),xc,yc,wid,len);
    end
end

ncircs = length(circs);
if ncircs > 0
    fprintf(fid, pformat('circ','s',3),'xc','yc','radius');
    for i = 1:ncircs
        xc = circs(i).center(1); yc = circs(i).center(2);
        radius = circs(i).radius;
        fprintf(fid,pformat('circ','f',3),xc,yc,radius);
    end
end

npples = length(pples);
if npples > 0
    fprintf(fid, pformat('person','s',3),'xc','yc','radius');
    for i = 1:npples
        xc = pples(i).center(1); yc = pples(i).center(2);
        radius = pples(i).radius;
        fprintf(fid,pformat('person','f',3),xc,yc,radius);
    end
end

fclose(fid);

%-----------------------------------------------------------------------

function [walls, exits, rects, circs, pples] = readscenarios(fname)
fid = fopen(fname,'r');
if fid == -1
    fprintf('Could not open input file "%s"\n', fname);
    return;
end

nwalls = 0; % number of walls
nexits = 0; % number of exits
nrects = 0; % number of rectangles
ncircs = 0; % number of circles
npples = 0; % number of people

tline = fgetl(fid);
while ischar(tline)
    data = regexp(strtrim(tline),'\s+','split');
    tline = fgetl(fid);
    
    keywords = data{1};
    if isempty(keywords)||keywords(1) == '%'; 
        continue; 
    end
    
    for i = 2:size(data,2);
        data{i}=str2num(data{i});
    end
    switch keywords
        case 'wall'
            [x1, y1, x2, y2] = data{2:5};
            nwalls = nwalls + 1;
            walls(nwalls) = wall([x1,y1], [x2,y2]);
        case 'exit'
            [x1, y1, x2, y2, strength, diameter] = data{2:7};
            nexits = nexits + 1;
            exits(nexits) = exit([x1, y1], [x2, y2], strength, diameter);
        case 'sign'
            [x, y, strength, diameter] = data{2:5};
            nexits = nexits + 1;
            exits(nexits) = exit([x, y], [x, y], strength, diameter);
        case 'rect'
            [x, y, width, length] = data{2:5};
            nrects = nrects + 1;
            rects(nrects) = rect([x, y], [width, length]);
        case 'circ'
            [x, y, radius] = data{2:4};
            ncircs = ncircs + 1;
            circs(ncircs) = circ([x, y], radius);
        case 'person'
            [x, y, radius] = data{2:4};
            npples = npples + 1;
            pples(npples) = person([x, y], radius);
    end
end

if nwalls == 0; walls = []; end;
if nexits == 0; exits = []; end;
if nrects == 0; rects = []; end;
if ncircs == 0; circs = []; end;
if npples == 0; pples = []; end;

%-----------------------------------------------------------------------

function formatstring = pformat(name, method, n)
switch method
    case 's'
        formatstring = ['\n%%',name,repmat('\t %6s',  1,n), '\n'];
    case 'f'
        formatstring = [' ',   name,repmat('\t %6.2f',1,n), '\n'];
end

%-----------------------------------------------------------------------

function obj = wall(p1, p2, radius)
if nargin <3; radius = 0; end
obj.p1 = p1;         % Endpoints of wall
obj.p2 = p2; 
obj.radius = radius; % Size of "Repulsion Field" around wall

%-----------------------------------------------------------------------
function obj = exit(p1, p2, strength, diameter)
% An exit is a wall that eats people
obj.p1 = p1; obj.p2 = p2;
obj.center = (p1+p2)/2;
obj.strength = strength;
obj.sign = false;
obj.diameter = diameter; % Search diameter for congestion
obj.congestion = 0;      
obj.nfolks =  0;         % Find out how many people are nearby

%-----------------------------------------------------------------------
function obj = rect(center, size)
% rect: A piece of square furniture, like a desk
obj.center = center;
obj.size = size;
vx = center(1) + size(1)/2*[-1 -1 +1 +1 -1];
vy = center(2) + size(2)/2*[-1  1  1 -1 -1];
obj.v = [vx' vy'];
obj.v1 = obj.v(1,:);
obj.v2 = obj.v(2,:);
obj.v3 = obj.v(3,:);
obj.v4 = obj.v(4,:);

%-----------------------------------------------------------------------

function obj = circ(center, radius)
% circ: A piece of round furniture
obj.center = center;
obj.radius = radius;

%-----------------------------------------------------------------------

function obj = person(center, radius)
% Person: A person is basically a piece of round furniture that moves
if nargin<2; radius  = 0.9306; end
obj.id = 0;
obj.center = center;
obj.radius = radius;
obj.v = 4; % People walk at 4.0 feet per second (always)
obj.exit = 0;
obj.stuck = false;
obj.exitime = [];
obj.dest = [];
obj.totalprogress = 0;
obj.lastprogress = 0;
obj.progress = zeros(30,1);
obj.nprogress= zeros(30,1);
