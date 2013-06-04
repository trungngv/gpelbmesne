function d = computeKernDist(x, model)
%COMPUTEKERNDIST  d = computeKernDist(x, model)
%   Distance from x to the centre of the MEB in the feature space induced
%   by the kernel function. 
%
%   Note computation can be saved if x is one of the training point (i.e.
%   kernel matrix can be reused).
%
% Trung V. Nguyen
centreNorm = model.alpha'*model.kern_matrix*model.alpha;
S = model.X(model.in_coreset,:);
N = size(x,1);
kxS = feval(model.kern_func,x,S,model.kern_hyp);
% TODO create diagkernel function for efficiency
kxx = feval(model.kern_func,x,x,model.kern_hyp);
d = repmat(centreNorm,N,1) - 2*kxS*model.alpha + diag(kxx);

