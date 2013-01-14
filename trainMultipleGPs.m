function models = trainMultipleGPs(XPartitions, YPartitions)
%TRAINMULTIPLEGPS trainMultipleGPs(XPartitions, YPartitions)
%
%   Trains multiple Gaussian process regression models corresponding to the
%   partitions given in XPartitions and YPartitions. If there are M
%   partitions, M models will be returned.
%
%   IMPORTANT: each GP is trained using the normalized data of a partition.
%   Hence prediction must be made w.r.t these normalized partitions.
%
%   Structure of a trained GP model:
%   - model.inithyp : the initialized hyp structure (same as in gpml by Carl Rasmussen)
%   - model.hyp     : the learned hyp structure
%   - model.nlm     : the negative log marginal likelihood of the model
%   - model.xmean, model.xstd : mean and std of input features
%   - model.ymean, model.ystd : mean and std of outputs
% 
% INPUT
%   - XPartitions: a cell where each element contains X -- the design
%   matrix (input features)
%   - YPartitions: a cell where each element contains Y -- the outputs
%
% OUTPUT
%   - models: a cell where each element is a trained GP model. 
%
% Trung V. Nguyen
% 14/01/13
%
covfunc = {@covSEard}; likfunc = @likGauss; infFunc = @infExact;

%matlabpool(4);
numPartitions = numel(XPartitions);
normalizedXPartitions = cell(size(XPartitions));
normalizedYPartitions = cell(size(YPartitions));
models = cell(size(XPartitions));
for i=1:numPartitions
  [normalizedXPartitions{i}, models{i}.xmean, models{i}.xstd] = standardize(XPartitions{i},1,[],[]);
  [normalizedYPartitions{i}, models{i}.ymean, models{i}.ystd] = standardize(YPartitions{i},1,[],[]);
end


D = size(XPartitions{1},2);
for i=1:numPartitions
  models{i}.inithyp.cov = [log(rand(D,1)); 0];
  models{i}.inithyp.lik = log(rand);
  [models{i}.hyp, models{i}.nlm] = minimize(models{i}.inithyp, @gp, 5000, ...
    infFunc, [], covfunc, likfunc, normalizedXPartitions{i}, normalizedYPartitions{i});
  models{i}.nlm = models{i}.nlm(end);
end

%predictive distribution
%[ystaaar s2 ystar] = gp(hyp, infFunc, [], covfunc, likfunc, X, Y, xtest);

end

