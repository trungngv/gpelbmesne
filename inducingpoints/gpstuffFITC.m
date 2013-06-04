function [smse,msll,fpred] = gpstuffFITC(x,y,xt,yt,xu,params,options)
%GPSTUFFFITC [smse,msll,fpred] = gpstuffFITC(x,y,xt,xu,params)
%   
%  Prediction with GP using FITC sparse approximation. Hyper-parameters and
%  inducing points are fixed (given). This method uses the GPstuff library.
%
%  All data are assumed to be un-normalised.
%
% Trung V. Nguyen
% 25/02/13

%TODO: careful with whether xu is standardised or not.
if ~isempty(options) && isfield(options,'normaliseData') && options.normaliseData
  [x,xmean,xstd] = standardize(x,1,[],[]);
  xu = standardize(xu,1,xmean,xstd);
  xt = standardize(xt,1,xmean,xstd);
  [normalized_y,ymean,ystd] = standardize(y,1,[],[]);
  normalized_yt = standardize(yt,1,ymean,ystd); % for computing log predictive probabilities
end

% set-up model
lik = lik_gaussian('sigma2',params.noiseSigma2);
gpcf = gpcf_sexp('lengthScale',params.lengthScale,'magnSigma2',params.magnSigma2);
gp_fic = gp_set('type','FIC','lik',lik,'cf',gpcf,'X_u',xu,'jitterSigma2',1e-4);
if ~isempty(options) && isfield(options,'infer_inducing') && options.infer_inducing
  %TODO: set savememory to on
  gp_fic = gp_set(gp_fic,'infer_params','inducing');
  opt = optimset('TolFun',1e-4,'TolX',1e-4,'Display','iter','LargeScale','on');
  % Optimize with the scaled conjugate gradient method
  gp_fic = gp_optim(gp_fic,x,y,'opt',opt);
end

% make prediction
% TODO shouldn't nlpd be computed using the untransformed targets (y and yt)?
if ~isempty(options) && isfield(options,'normaliseData') && options.normaliseData
  [fmean,fvar,logpred] = gp_pred(gp_fic,x,normalized_y,xt,'yt',normalized_yt);
  fpred = fmean*ystd + ymean;
else
  [fpred,fvar,logpred] = gp_pred(gp_fic,x,y,xt,'yt',yt);
end

smse = mysmse(yt,fpred,mean(y));
msll = -mean(logpred); % also try mynlpd

