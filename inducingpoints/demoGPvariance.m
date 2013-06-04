%clear; clc; close all;
rng(1110,'twister');

datasetsDir = '/home/trung/projects/datasets/';
datasetNames = {'kin40k','pumadyn32nm','myelevators','pol'};
fileNames = datasetNames;
% datasetNames = {'mysynth'};
% fileNames = {'synth1'};
daterun = date(); timestamp = num2str(tic);
M = 1000;
for id=1:length(datasetNames)
[X,Y,Xtest,Ytest] = load_data([datasetsDir datasetNames{id}], fileNames{id});
X = X(1:2000,:); Y = Y(1:2000,:);
D = size(X,2);
load([datasetsDir datasetNames{id} '/hyp.mat']);
name = datasetNames{id};
logger.(name).num_inducing = M;
tic;
[logger.(name).smse,logger.(name).msll] = gpvariance(hyp,X,Y,M,Xtest,Ytest,datasetNames{id});
logger.(name).times = toc;
save(['/home/trung/projects/ensemblegp/output/gpvariance' daterun '-' timestamp '.mat'], 'logger');
smse = logger.(name).smse;
msll = logger.(name).msll;
figure; plot(20*(1:length(smse)),smse,'x-'); title(['smse for ' datasetNames{id}]);
figure; plot(20*(1:length(msll)),msll,'x-'); title(['msll for ' datasetNames{id}]);
end
disp(['saved to /home/trung/projects/ensemblegp/output/gpvariance' daterun '-' timestamp '.mat'])

