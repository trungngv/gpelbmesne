clear; clc; close all;

%% synthetic dataset
% N = 1000;
% Ntest = 100;
% X = rand(N, 3);
% truef = @(X) X(:,1).^2 + sin(X(:,2)) + 0.5*X(:,3);
% Y = truef(X) + 0.1*randn(N,1);
% Xtest = rand(Ntest, 3);
% Ytest = truef(Xtest);

%% datasets in sparse spectrum
load('pumadyn32nm')
logger.dataset = 'pumadyn32nm';
X = X_tr;
Y = T_tr;
Xtest = X_tst;
Ytest = T_tst;
theaxis = [min(Y), max(Y), min(Y), max(Y)];

logger.X = X;
logger.Y = Y;
logger.Xtest = Xtest;
logger.Ytest = Ytest;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Init GP model for hyper-parameters
disp('training a init model')
iinit = randperm(length(X), 1024);
Xinit = X(iinit,:);
Yinit = Y(iinit,:);
initModel = standardGP([], Xinit, Yinit);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SUPPORT VECTOR CLUSTERING TRAINING
disp('fitting support vector clustering');
scales = linspace(2, 5, 5);
regularisers = linspace(0.1, 1, 5);
logger.scales = scales;
logger.regularisers = regularisers;

allX = [X; Xtest];
allX = standardize(allX,1,[],[]);
svcModel = crossValidateSVC(allX', scales, regularisers);
svcModel.options.method = 'RAND';
data = struct('X', allX');
svcModel = assignClusterLabels(data, svcModel);
logger.svcModel = svcModel;
fprintf('number of partitions %d\n', max(svcModel.cluster_labels));
fprintf('no. support vector %d\n', svcModel.nsv);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Prediction with single gp
% use all support vectors as inducing points
disp('maknig prediction with single gp using svc inducing points')
Xsv = X(svcModel.sv_ind(svcModel.sv_ind <= length(Y)),:);
Ysv = Y(svcModel.sv_ind(svcModel.sv_ind <= length(Y)),:);
if size(Xsv,1) <= 2000
  singlegp = standardGP(initModel, Xsv, Ysv, Xtest);
  logger.sgp.smse = mysmse(Ytest, singlegp.ymean);
  logger.sgp.mae = mean(abs(Ytest - singlegp.ymean));
  fprintf('single gp smse = %.4f\n', logger.sgp.smse);
  fprintf('single gp mae = %.4f\n', logger.sgp.mae);
  figure; scatter(Ytest, singlegp.ymean); title('single GP'); axis(theaxis);
%   plotMeanAndStd(Xtest, singlegp.ymean, singlegp.yvar + exp(singlegp.hyp.lik), [7 7 7]/8);
%   plot(Xtest, singlegp.ymean, '-r');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Prediction with svc partitions
disp('training gps for svc partitions')
partitions = getSVCPartitions(svcModel, X, Y, Xtest, Ytest);
fprintf('number of partitions: %d\n', size(partitions, 1));

% normalise data in each partition and train
for i=1:length(partitions)
  [partitions{i}.svX, partitions{i}.xmean, partitions{i}.xstd] = standardize(partitions{i}.svX,1,[],[]);
  [partitions{i}.svY, partitions{i}.ymean, partitions{i}.ystd] = standardize(partitions{i}.svY,1,[],[]);
end
models = trainMultipleGPs(initModel, partitions);

%% prediction with weighted combination of multiple gps
disp('making weighted prediction')
[ymu, yvar] = predictWeightedGPs(models, partitions, Xtest);
logger.svc.weightedgp.smse = mysmse(Ytest, ymu);
logger.svc.weightedgp.mae = mean(abs(Ytest - ymu));
fprintf('weighted combination smse = %.4f\n', logger.svc.weightedgp.smse);
fprintf('weighted combination mae = %.4f\n', logger.svc.weightedgp.mae);
figure; scatter(Ytest, ymu); title('weighted combination of gps'); axis(theaxis);
%plot(Xtest, ymu, '-b');

%% prediction with hard assignment to cluster
disp('making hard assignment prediction')
[yMeans, yVars] = predictHardAssignment(models, partitions);
ytest = []; ymu = [];
for i=1:length(partitions)
 ytest = [ytest; partitions{i}.Ytest];
 ymu = [ymu; yMeans{i}];
end
logger.svc.hardgp.smse = mysmse(ytest, ymu);
logger.svc.hardgp.mae = mean(abs(ytest - ymu));
fprintf('hard assignment smse = %.4f\n', logger.svc.hardgp.smse);
fprintf('hard assignment mae = %.4f\n', logger.svc.hardgp.mae);
figure; scatter(Ytest, ymu); title('hard assignment to gps'); axis(theaxis);
