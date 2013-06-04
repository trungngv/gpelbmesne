function isAdj = svcIsAdjacent(model, x, y, R)
%SVCISADJACENT isAdj = svcIsAdjacent(model, x, y, R)
%   Checks for adjacency of two points x and y.
%
isAdj = 1;
for interval = 0:0.1:1
  z = x + interval * (y - x);
  d = kdist2(z, model);
  if d > R
    isAdj = 0;
    break;
  end
end
end

