% zhou lvwen: zhou.lv.wen@gmail.com

function [varargout] = statisticalPlot(pples, time, dt, cellsize, varargin)
nout = 0;
for i = 1:length(varargin)
    switch varargin{i}
        case 'speed vs crowding'
            [nnearby, speed, nspeed] = speedvscrowding(pples, cellsize, dt);
            nout = nout + 1; varargout{nout} = nnearby;
            nout = nout + 1; varargout{nout} = speed;
            nout = nout + 1; varargout{nout} = nspeed;
        case 'number of people vs time'
            [ti, npplein] = npplevstime(pples, time, dt);
            nout = nout + 1; varargout{nout} = ti;
            nout = nout + 1; varargout{nout} = npplein;
    end
end

%-----------------------------------------------------------------------

function [nnearby, speed, nspeed] = speedvscrowding(pples, cellsize, dt)
progress = sum([pples.progress],2);
nspeed = sum([pples.nprogress],2);
speed = progress./nspeed/dt;
nnearby = [1:length(speed)]';
nnearby(isnan(speed)) = [];
speed(isnan(speed)) = [];
areaperperson = cellsize^2*9./nnearby;
figure
plot(areaperperson, speed, 'o-', 'linewidth', 2);
grid on
xlabel('Square Ft / Person');
ylabel('Walking Speed (ft/sec)')

%-----------------------------------------------------------------------

function [ti, npplein] = npplevstime(pples, time, dt)
npples = length(pples);
exitime = sort([pples.exitime]);
nppleout = zeros(1,ceil(time/dt));
for i = 1:npples
    ndt = ceil(exitime(i)/dt);
    nppleout(ndt) = nppleout(ndt) + 1;
end
npplein = npples - cumsum(nppleout);
ti = 0:dt:time;
figure
plot(ti, npplein);
grid on
xlabel('Time (sec)');
ylabel('Number of people in the system ')
