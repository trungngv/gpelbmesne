% train and save init hyp for kin40k
rng(1110,'twister');
datasetsDir = '/home/trung/projects/datasets/';
datasetNames = {'kin40k','myelevators','pol','pumadyn32nm'};
fileNames = datasetNames;
% datasetNames = {'mysynth'};
% fileNames = {'synth1'};
for i=1:length(datasetNames)
  [X,Y,~,~] = load_data([datasetsDir datasetNames{i}], fileNames{i});
  X = X(1:2000,:); Y = Y(1:2000,:);
  model = standardGP([],X,Y);
  hyp = model.hyp;
  save([datasetsDir datasetNames{i} '/hyp.mat'], 'hyp');
  disp(['learned hyper-parameters saved to ' datasetsDir datasetNames{i} '/hyp.mat']);
end

% prediction of full models on first 2000 training inputs
for i=1:length(datasetNames)
  disp(datasetNames{i})
  [X,Y,Xtest,Ytest] = load_data([datasetsDir datasetNames{i}], fileNames{i});
  X = X(1:2000,:); Y = Y(1:2000,:);
  load([datasetsDir datasetNames{i} '/hyp.mat']);
  Y0 = Y-mean(Y);
  Ytest0 = Ytest-mean(Y);
  [~,~,fpred,~,logpred] = gp(hyp,@infExact,[],{@covSEard},@likGauss,X,Y0,Xtest,Ytest0);
  fpred = fpred+mean(Y);
  smse = mysmse(Ytest,fpred,mean(Y))
  msll = -mean(logpred)
  save([datasetsDir datasetNames{i} '/evaluation.mat'], 'smse','msll');
end

