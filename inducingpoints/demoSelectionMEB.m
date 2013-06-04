% demo MEB selection for used with FITC approximation

%% load training and testing data
%clear; clc; close all;
datasetsDir = '/home/trung/projects/datasets/';
datasetNames = {'kin40k','myelevators','pumadyn32nm','pol'};
fileNames = datasetNames;
% datasetNames = {'mysynth'};
% fileNames = {'synth1'};
daterun = date(); timestamp = num2str(tic);

for id=1:length(datasetNames)
[X,Y,Xtest,Ytest] = load_data([datasetsDir datasetNames{id}], fileNames{id});
%X = X(1:2000,:); Y = Y(1:2000,:);
D = size(X,2);
load([datasetsDir datasetNames{id} '/hyp.mat']);
lengthscales = log((max(X)-min(X))'/2);
lengthscales(lengthscales<-1e2)=-1e2;
kernWidths = [linspace(0.05,0.2,10),linspace(0.25,0.5,10)];
kernhyp = cell(numel(kernWidths),1);
nTry = length(kernWidths);
for i=1:nTry
%   kernhyp{i+nTry} = kernWidths(i)*lengthscales;
  kernhyp{i} = kernWidths(i)*hyp.cov(1:end-1);
end
name = [datasetNames{id}];
ntry = length(kernhyp);
inducingInputs = cell(ntry,1);
logger.(name).kern_width = cell(ntry,1);
logger.(name).num_inducing = zeros(ntry,1);
logger.(name).smse = zeros(ntry,1);
logger.(name).msll = zeros(ntry,1);
for i=1:ntry
  try
    xu = selectInducingPoints('meb',X,[],kernhyp{i});
    %xu = selectInducingPoints('hybrid',X,[],kernhyp{i});
    if ~isempty(xu)
      M = size(xu,1);
      disp(['inducing points = ' num2str(M)]);
      inducingInputs{i} = xu;
    end  
  catch ee
    disp('error: probably out of memory')
  end
end
save(['inducingInputs' datasetNames{id} '.mat'],'inducingInputs');
for i=1:ntry
  if isempty(inducingInputs{i}), continue;  end;
  logger.(name).kern_width{i} = kernhyp{i};
  logger.(name).num_inducing(i) = size(inducingInputs{i},1);
  try
    [logger.(name).smse(i),logger.(name).msll(i)] = gpmlFITC(X,Y,Xtest,Ytest,inducingInputs{i},hyp);
  catch eee
    logger.(name).num_inducing(i) = 0;
  end
  disp([logger.(name).smse(i), logger.(name).msll(i)])
  save(['/home/trung/projects/ensemblegp/output/indpoints-hybrid-' daterun '-' timestamp '.mat'], 'logger');
end

end
disp(['saved to /home/trung/projects/ensemblegp/output/indpoints-hybrid-' daterun '-' timestamp '.mat'])
