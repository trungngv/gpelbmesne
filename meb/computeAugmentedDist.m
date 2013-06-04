function d = computeAugmentedDist(x, model)
%COMPUTEKERNDIST  d = computeAugmentedDist(x, model)
%   Distance from x to the centre of the MEB in the augmented feature space
%   induced by the kernel function. 
%
%   Note computation can be saved if x is one of the inducing point (i.e.
%   kernel matrix can be reused).
%
% Trung V. Nguyen
% 21/02/13
centreNorm = model.alpha'*model.kern_matrix*model.alpha;
s = model.X(model.in_coreset,:);
N = size(x,1);
kxs = feval(model.kern_func,x,s,model.kern_hyp);
p = parzenEstimator(x,model.X,log(0.5*exp(model.kern_hyp).^2));
d = repmat(centreNorm,N,1) - 2*kxs*model.alpha + 2*p + model.eta;

