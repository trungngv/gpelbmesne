%% Complete graph based SVC
% load('Aggregation.mat');
% data.X = standardize(X, 1, [], []);
% data.X = data.X';
% 
%use arg=0.5, C = 0.2 to get 2 clusters
% load('motorcycle.mat');
% data.X = times;
% data.X = standardize(data.X,1,[],[])';
% options = struct('method','CG','ker','rbf','arg',0.5,'C',0.2);
% [model] = svc(data,options);
% plotsvc(data,model);

%% SVC based clustering algorithms
rng(1110, 'twister');

% must set different scales depending on the datasets
% but scale > 0.3 is generally a good value as smaller scale tends to
% overfit the data
scales = linspace(0.3, 1, 5); % try 0.7 to 2 later
regularisers = linspace(0.1, 1, 5);

datasets = {'iris.mat', 'breast.mat', 'wine.mat','Aggregation.mat','Compound.mat'};
datasets = {'wine.mat'};
methods = {'DD', 'MST', 'KNN', 'RAND', 'SEP-CG', 'CG'};
%methods = {'DD'};
%methods = {'MST'};
%methods = {'KNN'};
%methods = {'RAND'};
%methods = {'SEP-CG'};
%methods = {'E-SVC'};
%methods = {'CG'};
nMethods = numel(methods);
nDatasets = length(datasets);
logger.raw.accuracyRates = zeros(nDatasets, nMethods);
logger.raw.runTimes = zeros(nDatasets, nMethods);
logger.norm.accuracyRates = zeros(nDatasets, nMethods);
logger.norm.runTimes = zeros(nDatasets, nMethods);
logger.pca.accuracyRates = zeros(nDatasets, nMethods);
logger.pca.runTimes = zeros(nDatasets, nMethods);

for idata = 1:nDatasets
  disp(['running ' datasets{idata}])
  % raw data
  data = load(['datasets/' datasets{idata}]);
  data.X = data.X';
  
  model = crossValidateSVC(data.X, scales, regularisers);
  for imethod=1:nMethods
    try
    if (strcmp(methods{imethod}, 'DD') || strcmp(methods{imethod},'CG'))...
        && length(data.X) > 500,  continue;  end
    model.options.method = methods{imethod};
    startTime = tic;
    [model] = assignClusterLabels(data, model);
    logger.raw.runTimes(idata, imethod) = toc(startTime);
    fprintf('\n%s time: %.4f(s)\n', model.options.method, logger.raw.runTimes(idata,imethod));
%     if (size(data.X,1) == 2),    plotsvc(data, model); end
    predictLabels = matchLabels(model.cluster_labels, data.Y);
    logger.raw.accuracyRates(idata,imethod) = sum(predictLabels(:) == data.Y(:))/length(data.Y);
  
    fprintf('%s accuracy rate = %.2f\n', methods{imethod}, logger.raw.accuracyRates(idata,imethod));
    catch, end
  end
  
  % standardized data
  data = load(['datasets/' datasets{idata}]);
  data.X = standardize(data.X,1,[],[]);
  data.X = data.X';
  
  model = crossValidateSVC(data.X, scales, regularisers);

  for imethod=1:nMethods
    try
    if (strcmp(methods{imethod}, 'DD') || strcmp(methods{imethod},'CG'))...
        && length(data.X) > 500,  continue;  end
    model.options.method = methods{imethod};
    startTime = tic;
    [model] = assignClusterLabels(data, model);
    logger.norm.runTimes(idata, imethod) = toc(startTime);
    fprintf('\n%s time: %.4f(s)\n', model.options.method, logger.norm.runTimes(idata,imethod));
%     if (size(data.X,1) == 2),    plotsvc(data, model); end
    predictLabels = matchLabels(model.cluster_labels, data.Y);
    logger.norm.accuracyRates(idata,imethod) = sum(predictLabels(:) == data.Y(:))/length(data.Y);
  
    fprintf('%s accuracy rate = %.2f\n', methods{imethod}, logger.norm.accuracyRates(idata,imethod));
    catch, end
  end
  
  % pca-ed data
  data = load(['datasets/' datasets{idata}]);
  data.X = standardize(data.X,1,[],[]); % mean centering first
  data.y = data.Y;
  data.X = data.X';
  model = pca(data.X, 2);
  data = linproj(data, model);
  data.Y = data.y;
  model = crossValidateSVC(data.X, scales, regularisers);
  
  for imethod=1:nMethods
    try
    if (strcmp(methods{imethod}, 'DD') || strcmp(methods{imethod},'CG'))...
        && length(data.X) > 500,  continue;  end
    model.options.method = methods{imethod};
    startTime = tic;
    [model] = assignClusterLabels(data, model);
    logger.pca.runTimes(idata, imethod) = toc(startTime);
    fprintf('\n%s time: %.4f(s)\n', model.options.method, logger.pca.runTimes(idata,imethod));
%     if (size(data.X,1) == 2),    plotsvc(data, model); end
    predictLabels = matchLabels(model.cluster_labels, data.Y);
    logger.pca.accuracyRates(idata,imethod) = sum(predictLabels(:) == data.Y(:))/length(data.Y);
  
    fprintf('%s accuracy rate = %.2f\n', methods{imethod}, logger.pca.accuracyRates(idata,imethod));
    catch, end
  end
end
