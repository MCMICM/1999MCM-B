% zhou lvwen: zhou.lv.wen@gmail.com

function unit_vectors = unit(V)
% unit computes the unit vectors of a matrix
% V is the input matrix
norms = sqrt(sum(V.^2,2));
unit_vectors = V./repmat(norms,1, 2);
