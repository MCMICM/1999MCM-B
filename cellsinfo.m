% zhou lvwen: zhou.lv.wen@gmail.com

function cells = cellsinfo(cells, varargin)
global walls exits rects circs ncell;

if isempty(cells)
    for i = 1:length(varargin);
        varname = varargin{i};
        if strcmp(varname,'grid'); continue; end;
        eval(['cells(ncell(1),ncell(2)).',varname,'=[];']);
    end
end

for n = 1:length(varargin)
    switch varargin{n}
        case 'walls'
            nwalls = length(walls);
            if nwalls == 0; continue; end
            p1 = cat(1,walls.p1); p2 = cat(1,walls.p2);
            cells = cellobj(nwalls,'walls', p1, p2, cells, ncell);
        case 'exits'
            nexits = length(exits);
            if nexits == 0; continue; end
            p1 = cat(1,exits.p1); p2 = cat(1,exits.p2);
            cells = cellobj(nexits,'exits', p1, p2, cells, ncell);
            exits = exitcell(exits);
        case 'rects'
            nrects = length(rects);
            if nrects == 0; continue; end
            p1 = cat(1, rects.center) - cat(1, rects.size)/2;
            p2 = cat(1, rects.center) + cat(1, rects.size)/2;
            cells = cellobj(nrects,'rects', p1, p2, cells, ncell);
        case 'circs'
            ncircs = length(circs);
            if ncircs == 0; continue; end
            p1 = cat(1, circs.center) - repmat(cat(1, circs.radius), 1, 2);
            p2 = cat(1, circs.center) + repmat(cat(1, circs.radius), 1, 2);
            cells = cellobj(ncircs,'circs', p1, p2, cells, ncell);
        case 'pples'
            cells = cellpples(cells);
        case 'visexit'
            nexits = length(exits);
            if nexits == 0; continue; end
            cells = visexit(cells);
        case 'neighbor'
            cells = neighbor(cells);
        case 'congestion'
            nexits = length(exits);
            exits = getcongestion(exits, cells);
        case 'grid'
            plotcell();
    end
end

%-----------------------------------------------------------------------

function exits = exitcell(exits)
global xmin ymin cellsize ncell;
nexits = length(exits);

for k = 1:nexits
    sub = ceil((exits(k).center-[xmin,ymin])/cellsize);
    dist = ceil(exits(k).diameter/cellsize);
    cell = [];
    for j = sub(2)-dist:sub(2)+dist
        for i = sub(1)-dist:sub(1)+dist
            if i<1 || i>ncell(1)||j<1||j>ncell(2); continue;end
            ind = sub2ind(ncell, i, j);
            cell = [cell ind];
        end
    end
    cell(cell==0)=[];
    exits(k).cell = cell;
end

%-----------------------------------------------------------------------

function exits = getcongestion(exits, cells)
% Calculate the congestion near the exit
nexits = length(exits);
for k = 1:nexits
    exits(k).nfolks = sum([cells(exits(k).cell).nfolks]);
    congestion = exits(k).nfolks/50;
    exits(k).congestion = congestion/(congestion + 1);
end

%-----------------------------------------------------------------------

function cells = cellpples(cells)
global pples xmin ymin cellsize ncell;
npples = length(pples);
[cells.nfolks] = deal(0);
[cells.pples] = deal(zeros(30,1)); 
[cells.npples] = deal(0);
for k = 1:npples
    if pples(k).exitime; continue; end
    sub = ceil((pples(k).center-[xmin,ymin])/cellsize);
    pples(k).cell = sub;
    cells(sub(1), sub(2)).nfolks = cells(sub(1), sub(2)).nfolks + 1;
    imin = max(sub(1)-1,1); imax = min(sub(1)+1,ncell(1));
    jmin = max(sub(2)-1,1); jmax = min(sub(2)+1,ncell(2));
    
    for j = jmin:jmax
        for i = imin:imax
            cells(i,j).npples=cells(i,j).npples+1;
            cells(i,j).pples(cells(i,j).npples) =  k;
        end
    end
end

for i = 1:ncell(1)*ncell(2)
    cells(i).pples(cells(i).npples+1:end)=[];
end

%-----------------------------------------------------------------------

function cells = cellobj(nobjs, objname, p1, p2, cells, ncell)
global xmin ymin cellsize;

for k = 1:nobjs
    sub(1,:) = ceil( (p1(k,:)-[xmin,ymin]) / cellsize );
    sub(2,:) = ceil( (p2(k,:)-[xmin,ymin]) / cellsize );
    sub = sort(sub);
    imin = sub(1,1)-1; imin = max(imin,1);
    imax = sub(2,1)+1; imax = min(imax,ncell(1));
    jmin = sub(1,2)-1; jmin = max(jmin,1);
    jmax = sub(2,2)+1; jmax = min(jmax,ncell(2));
    for j = jmin:jmax;
        for i = imin:imax;
            eval(['cells(i,j).',objname,'(end+1)= k;']);
        end
    end
end

%-----------------------------------------------------------------------

function plotcell
global xmin ymin xmax ymax cellsize;
hold on
for xc = xmin:cellsize:xmax; 
    h = plot([xc xc], [ymin ymax],'color',[0.6,0.6,0.6]); 
    uistack(h, 'bottom')
end
for yc = ymin:cellsize:ymax; 
    h = plot([xmin xmax], [yc yc],'color',[0.6,0.6,0.6]); 
    uistack(h, 'bottom')
end
hold off

%-----------------------------------------------------------------------

function cells = visexit(cells)
global exits xmin ymin cellsize ncell;

nexits = length(exits);
for j = 1:ncell(2)
    for i = 1:ncell(1)
        center = [xmin ymin]+[i-0.5,j-0.5]*cellsize;
        visexit = [];
        for ni = 1:nexits
            if visible(center , exits(ni).center) % This exit is visible
                visexit = [visexit ni];
            end
        end
        cells(i,j).visexit = visexit;
    end
end

%-----------------------------------------------------------------------

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

function cells = neighbor(cells)
ncell = size(cells);
for j = 1:ncell(2)
    jmin = max(j-1,1); jmax = min(j+1,ncell(2));
    for i = 1:ncell(1)
        imin = max(i-1,1); imax = min(i+1,ncell(1));
        neighbor = [];
        for nj = jmin:jmax
            for ni = imin:imax
                neighbor = [neighbor sub2ind(ncell, ni, nj)];
            end
        end
        cells(i,j).neighbor = neighbor;
    end
end
