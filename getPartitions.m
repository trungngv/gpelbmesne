function [XPartitions, YPartitions] = getPartitions(tree)
%GETPARTITIONS [XPartitions, YPartitions] = getPartitions(tree)
%
% Returns the partitions of the dataset by a regression tree trained with
% RegressionTree.fit. The output variables are cells where each element of
% the cell corresponds to a partition.
% 
% Trung V. Nguyen
% 14/01/13
yhat = predict(tree, tree.X);
partitionMean = unique(yhat); % means of all leaf nodes
numPartitions = numel(partitionMean);
XPartitions = cell(numPartitions,1);
YPartitions = cell(numPartitions,1);
for i=1:numPartitions
  XPartitions{i} = tree.X(yhat == partitionMean(i),:);
  YPartitions{i} = tree.Y(yhat == partitionMean(i));
end
end

