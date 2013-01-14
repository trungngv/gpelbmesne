function output = standardGP(X, Y, Xtest)
%STANDARDGP Quick wrapper for a standard GP regressor.
%
% OUTPUT: a structure with following members
%   - ymean : predictive mean
%   - yvar : predictive variance
%   - nlm : negative log marginal
%   - inithyp: initial hyp
%   - hyp: learned hyp
%
% Trung V. Nguyen
% 14/01/13

% transform data
[X, xmean, xstd] = standardize(X,1,[],[]);
[Y, ymean, ystd] = standardize(Y,1,[],[]);
D = size(X, 2);

% init and train model
covfunc = {@covSEard}; likfunc = @likGauss; infFunc = @infExact;
output.inithyp.cov = [log(rand(D,1)); 0];
output.inithyp.lik = log(rand);
[output.hyp, output.nlm] = minimize(output.inithyp, @gp, 5000, ...
    infFunc, [], covfunc, likfunc, X, Y);
output.nlm = output.nlm(end);

% prediction
[~, output.yvar, output.ymean] = gp(output.hyp, infFunc, [], covfunc, likfunc, ...,
    X, Y, standardize(Xtest,1, xmean, xstd));
output.ymean = output.ymean .* ystd + ymean;

end

