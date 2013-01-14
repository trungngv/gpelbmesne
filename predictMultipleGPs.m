function [ymu, yvar] = predictMultipleGPs(models, XPartitions, YPartitions, Xtest)
%PREDICTMULTIPLEGPS [Ymean, Yvar] = predictMultipleGPs(models, Xtest, Ytest)
%   Weighted prediction using multiple GPs.
%
% INPUT
%   - models : trained GP models for all partitions
%   - XPartitions, YPartitions : input and outputs of all partitions
%   - Xtest : test input points
%
% OUTPUT
%   - Ymean, Yvar
%
% Trung V. Nguyen
% 14/01/13
covfunc = {@covSEard}; likfunc = @likGauss; infFunc = @infExact;

% Must normalize data to be consistent with training procedure
nPartitions = size(XPartitions,1);
normalizedXPartitions = cell(size(XPartitions));
normalizedYPartitions = cell(size(YPartitions));
for i=1:nPartitions
  normalizedXPartitions{i} = standardize(XPartitions{i},1,[],[]);
  normalizedYPartitions{i} = standardize(YPartitions{i},1,[],[]);
end

yMeans = zeros(size(Xtest,1),size(models,1)); % Ntest x M
yVars = yMeans;
for i=1:nPartitions
  [~, yVars(:,i), yMeans(:,i)] = gp(models{i}.hyp, infFunc, [], covfunc, likfunc, ...,
    normalizedXPartitions{i}, normalizedYPartitions{i}, standardize(Xtest,1,models{i}.xmean, models{i}.xstd));
  yMeans(:,i) = yMeans(:,i) .* models{i}.ystd + models{i}.ymean;
end
sumInverseVariance = sum(1./yVars, 2); % norm constant of weights
ymu = sum(yMeans./yVars, 2) ./ sumInverseVariance; % weighted prediction
yvar = zeros(size(ymu)); % TODO
end

