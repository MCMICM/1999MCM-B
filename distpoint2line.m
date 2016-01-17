% zhou lvwen: zhou.lv.wen@gmail.com

function [dist, hitPt] = distpoint2line(pple, t1, t2) 
% Distance from point to the nearest point along a line segment 

P = repmat(pple.center,size(t1,1),1);
a = sum((t2 - t1).^2,2); 
t = sum((t1-P).*(t1-t2),2)./a;
hitPt = t1+[t,t].*(t2-t1);
hitPt(t<0,:) = t1(t<0,:);
hitPt(t>1,:) = t2(t>1,:);

dist = sqrt(sum( (P-hitPt).^2, 2 )) - pple.radius;
