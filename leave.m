% zhou lvwen: zhou.lv.wen@gmail.com

function [pple, nleave] = leave(pple, nleave, time)
% Can we leave yet?
if ifatexit(pple) % Check to see if they're at an exit
    % This person has reached an exit and is ready to leave
    pple.exitime = time;
    pple.center = [inf inf];
    nleave = nleave + 1; % Increment saved-counter
end

%-----------------------------------------------------------------------

function isatexit = ifatexit(pple)
% Can person p leave via exit now?
global exits;
% No exit, even   || This is just a warning sign, not an exit!
if pple.exit == 0 || exits(pple.exit).strength < 0
    isatexit = 0;
    return;
end 

p1 = exits(pple.exit).p1;
p2 = exits(pple.exit).p2;

[dist, hitPt] = distpoint2line(pple, p1, p2);
if dist<0 % Person is penetrating exit-- let them leave
    isatexit = 1; % We're saved!
else      % Person is not penetrating exit-- they stay.
    isatexit = 0; % We can't leave yet...
end
