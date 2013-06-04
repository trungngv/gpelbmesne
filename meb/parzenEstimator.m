function p = parzenEstimator(Z,X,hyp)
%PARZENESTIMATOR p = parzenEstimator(Z,X,hyp)
%  
% Compute the Parzen density estimate for all points in Z using the
% Gaussian density kernel with lengthscales (hyperparameters)
% ell=exp(hyp)^2.
% 
% p(i) = p(z_i) := (1/N)*\sum_{j=1}^N G(z_i; x_j)
%
% INPUT
%   - Z : M x d 
%   - X : N x d
%   
% OUTPUT
%   - p : N x 1 vector where p(i) is the density estimate of point i
%
% TODO: approximate p(i) using say L points for efficiency
N = size(X,1);
Kzx = gaussDensityKern(Z,X,hyp);
p = sum(Kzx,2)/N;
end

