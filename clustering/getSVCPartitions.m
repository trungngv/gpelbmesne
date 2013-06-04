function partitions = getSVCPartitions(svcModel, X, Y, Xtest, Ytest)
%GETPARTITIONS partitions = getSVCPartitions(svcModel, X, Xtest, Y, Ytest)
%
% Returns the partitions of the dataset by a svc model. 
%
% INPUT
%   - svcModel : a trained svc model with cluster labels for the
%   concatenation of X and Xtest, i.e. [X; Xtest]
%   - X, Y, Xtest, Ytest : training inputs, training outputs, test inputs, test
%   outputs
%
% OUTPUT
%   - partitions (structure)
%        .X, .Y, .Xtest, .Ytest
%
% Trung V. Nguyen
% 07/02/13
nParts = max(svcModel.cluster_labels);
partitions = cell(nParts, 1);
allInd = 1:length(svcModel.cluster_labels);
svInd = svcModel.sv_ind(svcModel.sv_ind <= length(Y));
for i=1:nParts
  ind = allInd(svcModel.cluster_labels == i); % point in partition
  partitions{i}.Xtest = Xtest(ind(ind > length(Y)) - length(Y),:);
  partitions{i}.Ytest = Ytest(ind(ind > length(Y)) - length(Y),:);
  trainInd = ind(ind <= length(Y)); % training indice of this partition
  partitions{i}.X = X(trainInd,:);
  partitions{i}.Y = Y(trainInd,:);
  % sv of partition i = points in partition i as well as in sv
  partitions{i}.svX = X(intersect(trainInd, svInd),:);
  partitions{i}.svY = Y(intersect(trainInd, svInd),:);
end

