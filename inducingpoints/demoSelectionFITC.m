% demo selection methods for used with FITC approximation

%% load training and testing data
%clear; clc; close all;
datasetsDir = '/home/trung/projects/datasets/';
datasetNames = {'kin40k','pumadyn32nm','myelevators','pol'};
fileNames = datasetNames;
% datasetNames = {'mysynth'};
% fileNames = {'synth1'};
daterun = date(); timestamp = num2str(tic);

for id=1:length(datasetNames)
[X,Y,Xtest,Ytest] = load_data([datasetsDir datasetNames{id}], fileNames{id});
%X = X(1:2000,:); Y = Y(1:2000,:);
D = size(X,2);

%% inducing point selection methods
if strcmp(datasetNames{id},'mysynth')
  Mspace = [10 50 100 200 500];
  params.lengthScale = [1 1.5 0.4 2.5 0.1];
  params.magnSigma2 = 1;
  params.noiseSigma2 = 0.01^2;
  hyp.cov = log([params.lengthScale(:); sqrt(params.magnSigma2)]);
  hyp.lik = log(sqrt(params.noiseSigma2));
else
  Mspace = [500 750 1000];
  load([datasetsDir datasetNames{id} '/hyp.mat']);
  params.lengthScale = exp(hyp.cov(1:end-1));
  params.magnSigma2 = exp(2*hyp.cov(end));
  params.noiseSigma2 = exp(2*hyp.lik);
end

methods = {'optim'};
for M=Mspace
  fprintf('using %d inducing points\n',M);
  kernhyp = log(params.lengthScale);
  name = [datasetNames{id} 'Inducing' num2str(M)];
  logger.(name).params = params;
  logger.(name).note = 'kern width of RSDE same as GP;sensible initialisation of GP hyper';
  logger.(name).times = zeros(length(methods),1);
  logger.(name).kern_width = log(params.lengthScale);% kernhyp;
  logger.(name).num_inducing = M;
  logger.(name).methods = methods;
  logger.(name).smse = zeros(length(methods),1);
  logger.(name).msll = zeros(length(methods),1);
  for i=1:length(methods)
    disp(['running ' methods{i}])
%   try
    tic;
    if strcmp(methods{i},'ivm') || strcmp(methods{i},'optim')
      xu = selectInducingPoints(methods{i},X,M,log([params.lengthScale(:);...
          sqrt(params.magnSigma2)]),log(sqrt(params.noiseSigma2)),Y);
    else
      xu = selectInducingPoints(methods{i},X,M,kernhyp);
    end  
    [logger.(name).smse(i),logger.(name).msll(i)] = gpmlFITC(X,Y,Xtest,Ytest,xu,hyp);
    logger.(name).times(i) = toc;
    save(['/home/trung/projects/ensemblegp/output/indpoints' daterun '-' timestamp '.mat'], 'logger');
%   catch e
%     error(e.message)
%   end
  end
end
end
disp(['saved to /home/trung/projects/ensemblegp/output/indpoints' daterun '-' timestamp '.mat'])
