function [adjacent] = computeAdjMatrix(X,gpmodel,normalizedData)
%computeAdjMatrix [adjacent] = computeAdjMatrix(X, gpmodel, normalized)
%
% INPUT:
%   - X : input data (N x d) 
%   - gpmodel : [struct] a trained GP model
%   - normalized : true if X is normalized
%
% OUTPUT:
%   - adjacent : adjacency matrix of size N x N with 
%       1 for connected, 0 for disconnected (violated), -1 (outliers, BSV)
%
% Description
%	The Adjacency matrix between pairs of points whose images lie in
%	or on the sphere in feature space. 
%	(i.e. points that belongs to one of the clusters in the data space)
%
%	given a pair of data points that belong to different clusters,
%	any path that connects them must exit from the sphere in feature
%	space. Such a path contains a line segment of points y, such that:
%	kdist2(y,model)>model.r.
%	Checking the line segment is implemented by sampling a number of 
%   points (10 points).
%
% 24/01/13
% Trung V. Nguyen

epsilon = 1e-10;
[N, D] = size(X);
adjacent = eye(N);
if ~normalizedData
  X = standardize(X,1,[],[]);
end
% TODO predictive mean is not needed for clustering so may save computation
% by implementing a routine for computing predictive variance only
[~, ~, ~, fvars] = gp(gpmodel.hyp, gpmodel.infFunc, [], gpmodel.covfunc, ...
  gpmodel.likfunc, X, zeros(N,1), X);
 R = max(fvars) + epsilon;
%R = mean(fvars) + epsilon;
% R = median(fvars);
post = [];

for i = 1:N %rows
  for j = 1:N %columns
    % if the j is adjacent to i - then all j adjacent's are also adjacent to i.
    if j<i
      if (adjacent(i,j) == 1)
        adjacent(i,:) = (adjacent(i,:) | adjacent(j,:));
      end
    elseif (adjacent(i,j) ~= 1) % if adajecancy already found - no point in checking again
      adj_flag = 1; % unless a point on the path exits the shpere - the points are adjacnet
      for interval = 0:0.1:1
        z = X(i,:) + interval * (X(j,:) - X(i,:));
        [~, ~, ~, zvar] = gp(gpmodel.hyp, gpmodel.infFunc, [], gpmodel.covfunc, ...
          gpmodel.likfunc, X, zeros(N, 1), z);
%         [~,~,~, zvar, ~, post] = mygp(post, gpmodel.hyp, gpmodel.infFunc, [], gpmodel.covfunc, ...
%           gpmodel.likfunc, X, zeros(N, 1), z);
        if zvar > R
          adj_flag = 0;
          break;
        end
      end
      if adj_flag == 1
        adjacent(i,j) = 1;
        adjacent(j,i) = 1;
      end
      % this batch operation is more expensive due to not having early breaking
%       interval = (0:0.1:1)';
%       npoints = size(interval, 1);
%       z = repmat(X(i,:), npoints, 1) + repmat(interval, 1, D) .* repmat(X(j,:)-X(i,:), npoints, 1);
%       [~, zVars, ~] = gp(gpmodel.hyp, gpmodel.infFunc, [], gpmodel.covfunc, ...
%         gpmodel.likfunc, X, zeros(N, 1), z);
%       adjacent(i,j) = ~any(zVars > R);
%       adjacent(j,i) = adjacent(i,j);

    end
  end
end

end
