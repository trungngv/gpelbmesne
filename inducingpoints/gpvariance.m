function [smse,msll] = gpvariance(hyp,x,y,M,xt,yt,datasetName)
%GPVARIANCE model = gpvariance(x,y,M,xt,yt)
%   
% output is zeroed mean
y0 = y-mean(y);
likfunc = @likGauss;

% init hyperparameters if not given
if isempty(hyp)
  lengthscales = log((max(x)-min(x))'/2);
  lengthscales(lengthscales<-1e2)=-1e2;
  hyp.cov = [lengthscales; 0.5*log(var(y0,1))];
  hyp.lik = 0.5*log(var(y0,1)/4);
end

% initial inducing points
Minit = 20;
[~,xu] = selectInducingPoints('kmeans',x,Minit,hyp.cov,hyp.lik);
covfunc = {@covFITC,{@covSEard},xu};
inducing = zeros(size(x,1),1);
Ns = 70; nIter = M-Minit; %M-Minit
maxVar = zeros(nIter,1);
smse = []; msll = [];
i=1;
while i <= nIter
  %sampleInd = randsample(find(~inducing),Ns,false);
  sampleInd = randsample(1:size(x,1),Ns,false);
  [~,~,~,predVar] = gp(hyp,@infFITC,[],covfunc,likfunc,x,y0,x(sampleInd,:));
  [maxVar(i),maxIdx] = max(predVar);
  nextIdx = sampleInd(maxIdx);
  inducing(nextIdx) = 1;
  xu = [xu; x(nextIdx,:)];
  i = i+1;
  covfunc = {@covFITC,{@covSEard},xu};
  hyp = minimize(hyp,@gp,-50,{@infFITC},[],covfunc,likfunc,x,y);
  if mod(Minit+i,20) == 1
    % make prediction
    [thizsmse,thizmsll,~] = gpmlFITC(x,y,xt,yt,xu,hyp);
    smse = [smse;thizsmse];
    msll = [msll;thizmsll];
  end
end

figure; hold off;
plot(maxVar,'x-');
title(['max variance vs. iterations' datasetName]);

