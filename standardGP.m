<<<<<<< HEAD
function output = standardGP(X, Y, Xtest)
%STANDARDGP Quick wrapper for a standard GP regressor.
%
% OUTPUT: a structure with following members
%   - ymean : predictive mean
%   - yvar : predictive variance
%   - nlm : negative log marginal
=======
function model = standardGP(initModel,X,Y,Xtest,Ytest)
%STANDARDGP model = standardGP(initModel,X,Y,Xtest,Ytest)
%   Quick wrapper for a standard GP model.
%   No data pre-processing for input is performed by this method. The
%   output is transformed to have zero mean.
%
% INPUT
%   - initModel : init the gp from this init model (empty if not available)
%   - X : input data (N x d)
%   - Y : output data (N x 1)
%   - Xtest : test input data (can be optional or empty)
%   - Ytest : output (for evaluation only; can be optional or empty)
%
% OUTPUT: the trained model as a structure with following members
>>>>>>> parent of 58a7b8e... refactor; minor modification for standard gp
%   - inithyp: initial hyp
%   - hyp: learned hyp
%
% Trung V. Nguyen
% 14/01/13
<<<<<<< HEAD

% transform data
[X, xmean, xstd] = standardize(X,1,[],[]);
[Y, ymean, ystd] = standardize(Y,1,[],[]);
D = size(X, 2);
=======
% init and train model
model.covfunc = {@covSEard}; %covfunc = {@covSEiso};
model.likfunc = @likGauss;
model.infFunc = @infExact;
Y0 = Y-mean(Y); % zero-mean the outputs

if ~isempty(initModel)
  model.inithyp = initModel.hyp;
else
  lengthscales = log((max(X)-min(X))'/2);
  lengthscales(lengthscales<-1e2)=-1e2;
  model.inithyp.cov = [lengthscales; 0.5*log(var(Y0,1))];
  model.inithyp.lik = 0.5*log(var(Y0,1)/4);
end
>>>>>>> parent of 58a7b8e... refactor; minor modification for standard gp

% init and train model
covfunc = {@covSEard}; likfunc = @likGauss; infFunc = @infExact;
output.inithyp.cov = [log(rand(D,1)); 0];
output.inithyp.lik = log(rand);
[output.hyp, output.nlm] = minimize(output.inithyp, @gp, 5000, ...
    infFunc, [], covfunc, likfunc, X, Y);
output.nlm = output.nlm(end);

% prediction
<<<<<<< HEAD
[~, output.yvar, output.ymean] = gp(output.hyp, infFunc, [], covfunc, likfunc, ...,
    X, Y, standardize(Xtest,1, xmean, xstd));
output.ymean = output.ymean .* ystd + ymean;

=======
if nargin >= 4
  if ~isempty(Ytest)
    [~,model.yvar,model.ymean,~,model.lp] = gp(model.hyp,model.infFunc,[],model.covfunc,...
      model.likfunc,X,Y,Xtest,Ytest-mean(Y));
  else
    [~,model.yvar,model.ymean,~] = gp(model.hyp,model.infFunc,[],model.covfunc,...
      model.likfunc,X,Y,Xtest);
  end
  model.ymean = model.ymean + mean(Y);
end
>>>>>>> parent of 58a7b8e... refactor; minor modification for standard gp
end

